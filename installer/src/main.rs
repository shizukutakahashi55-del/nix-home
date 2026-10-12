use std::{
    env, fs,
    path::{Component, Path, PathBuf},
    process::Command,
};

// ───────────────────────── Salida JSON (sin dependencias) ─────────────────────────

enum J {
    Null,
    Bool(bool),
    Num(usize),
    Str(String),
    Arr(Vec<J>),
    Obj(Vec<(&'static str, J)>),
}

fn esc(s: &str) -> String {
    let mut o = String::with_capacity(s.len() + 2);
    o.push('"');
    for c in s.chars() {
        match c {
            '"' => o.push_str("\\\""),
            '\\' => o.push_str("\\\\"),
            '\n' => o.push_str("\\n"),
            '\r' => o.push_str("\\r"),
            '\t' => o.push_str("\\t"),
            c if (c as u32) < 0x20 => o.push_str(&format!("\\u{:04x}", c as u32)),
            c => o.push(c),
        }
    }
    o.push('"');
    o
}

impl J {
    fn render(&self) -> String {
        match self {
            J::Null => "null".into(),
            J::Bool(b) => b.to_string(),
            J::Num(n) => n.to_string(),
            J::Str(s) => esc(s),
            J::Arr(a) => format!("[{}]", a.iter().map(J::render).collect::<Vec<_>>().join(",")),
            J::Obj(o) => format!(
                "{{{}}}",
                o.iter().map(|(k, v)| format!("{}:{}", esc(k), v.render())).collect::<Vec<_>>().join(",")
            ),
        }
    }
}

fn s(x: impl Into<String>) -> J {
    J::Str(x.into())
}

fn emit(ok: bool, data: J, error: Option<String>) {
    let err = error.map(J::Str).unwrap_or(J::Null);
    println!("{}", J::Obj(vec![("ok", J::Bool(ok)), ("data", data), ("error", err)]).render());
}

fn fail(msg: impl Into<String>) {
    emit(false, J::Null, Some(msg.into()));
}

// ───────────────────────── Repositorio ─────────────────────────

fn find_repo(start: &Path) -> Option<PathBuf> {
    let mut current = start.canonicalize().ok()?;
    loop {
        if current.join("flake.nix").exists() && current.join("configuration.nix").exists() {
            return Some(current);
        }
        if !current.pop() {
            return None;
        }
    }
}

fn resolve_repo(arg: Option<&String>) -> Result<PathBuf, String> {
    let start = arg
        .filter(|a| !a.is_empty())
        .map(PathBuf::from)
        .or_else(|| env::var("NIXHOME_REPO").ok().map(PathBuf::from))
        .unwrap_or_else(|| env::current_dir().unwrap_or_else(|_| PathBuf::from(".")));
    find_repo(&start).ok_or_else(|| {
        "No encontré flake.nix y configuration.nix en esa ruta ni en sus directorios superiores.".into()
    })
}

fn safe_rel(repo: &Path, rel: &str) -> Result<PathBuf, String> {
    let p = Path::new(rel);
    if p.is_absolute() || p.components().any(|c| matches!(c, Component::ParentDir)) {
        return Err("Ruta fuera del repositorio.".into());
    }
    if p.extension().and_then(|e| e.to_str()) != Some("nix") {
        return Err("Solo se pueden editar archivos .nix.".into());
    }
    let full = repo.join(p);
    if !full.is_file() {
        return Err(format!("No existe {rel}."));
    }
    Ok(full)
}

fn collect_nix_files(root: &Path, dir: &Path, out: &mut Vec<PathBuf>) {
    let Ok(entries) = fs::read_dir(dir) else { return };
    for entry in entries.flatten() {
        let path = entry.path();
        let name = path.file_name().and_then(|x| x.to_str()).unwrap_or("");
        if name == ".git" || name == ".installer" || name.starts_with("result") || name == "target" {
            continue;
        }
        if path.is_dir() {
            collect_nix_files(root, &path, out);
        } else if path.extension().and_then(|x| x.to_str()) == Some("nix") {
            out.push(path);
        }
    }
}

fn rel_of(repo: &Path, p: &Path) -> String {
    p.strip_prefix(repo).unwrap_or(p).display().to_string()
}

// ───────────────────────── Snapshots ─────────────────────────

fn snap_dir(repo: &Path) -> PathBuf {
    repo.join(".installer").join("snapshots")
}

fn snap_path(repo: &Path, rel: &str) -> PathBuf {
    snap_dir(repo).join(rel)
}

fn ensure_ignored(repo: &Path) {
    let gi = repo.join(".gitignore");
    let cur = fs::read_to_string(&gi).unwrap_or_default();
    if !cur.lines().any(|l| l.trim() == ".installer/" || l.trim() == ".installer") {
        let mut next = cur;
        if !next.is_empty() && !next.ends_with('\n') {
            next.push('\n');
        }
        next.push_str(".installer/\n");
        let _ = fs::write(gi, next);
    }
}

fn snapshot(repo: &Path, rel: &str) -> Result<(), String> {
    let src = safe_rel(repo, rel)?;
    let dst = snap_path(repo, rel);
    if dst.exists() {
        return Ok(());
    }
    if let Some(parent) = dst.parent() {
        fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    fs::copy(&src, &dst).map_err(|e| e.to_string())?;
    ensure_ignored(repo);
    Ok(())
}

fn write_atomic(path: &Path, contents: &str) -> Result<(), String> {
    let tmp = path.with_extension("nix.installer-tmp");
    fs::write(&tmp, contents).map_err(|e| e.to_string())?;
    if let Ok(meta) = fs::metadata(path) {
        let _ = fs::set_permissions(&tmp, meta.permissions());
    }
    fs::rename(&tmp, path).map_err(|e| e.to_string())
}

fn snapshot_files(repo: &Path) -> Vec<String> {
    let base = snap_dir(repo);
    let mut out = Vec::new();
    let mut all = Vec::new();
    collect_any(&base, &mut all);
    for p in all {
        if let Ok(rel) = p.strip_prefix(&base) {
            out.push(rel.display().to_string());
        }
    }
    out.sort();
    out
}

fn collect_any(dir: &Path, out: &mut Vec<PathBuf>) {
    let Ok(entries) = fs::read_dir(dir) else { return };
    for e in entries.flatten() {
        let p = e.path();
        if p.is_dir() {
            collect_any(&p, out);
        } else {
            out.push(p);
        }
    }
}

// ───────────────────────── Análisis de listas ─────────────────────────

#[derive(Debug, Clone)]
struct PkgList {
    kind: &'static str,
    open_line: usize,
    close_line: usize,
    with_pkgs: bool,
    single_line: bool,
    entries: Vec<(String, usize)>,
}

fn is_ident(s: &str) -> bool {
    let mut seg_start = true;
    if s.is_empty() {
        return false;
    }
    for ch in s.chars() {
        if seg_start {
            if !(ch.is_ascii_alphabetic() || ch == '_') {
                return false;
            }
            seg_start = false;
        } else if ch == '.' {
            seg_start = true;
        } else if !(ch.is_ascii_alphanumeric() || ch == '_' || ch == '-' || ch == '\'') {
            return false;
        }
    }
    !seg_start
}

fn strip_comment(line: &str) -> String {
    let mut in_str = false;
    let chars: Vec<char> = line.chars().collect();
    let mut out = String::new();
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        if c == '"' {
            in_str = !in_str;
        }
        if !in_str && c == '#' {
            break;
        }
        out.push(c);
        i += 1;
    }
    out
}

fn depth_delta(s: &str) -> i32 {
    let mut d = 0;
    let mut in_str = false;
    for c in s.chars() {
        match c {
            '"' => in_str = !in_str,
            '[' | '(' | '{' if !in_str => d += 1,
            ']' | ')' | '}' if !in_str => d -= 1,
            _ => {}
        }
    }
    d
}

fn find_lists(text: &str) -> Vec<PkgList> {
    let lines: Vec<&str> = text.lines().collect();
    let mut lists = Vec::new();
    let mut i = 0;
    while i < lines.len() {
        let code = strip_comment(lines[i]);
        let mut t = code.trim();
        let kind = if let Some(p) = t.find("home.packages") {
            t = &t[p..];
            "home"
        } else if let Some(p) = t.find("environment.systemPackages") {
            t = &t[p..];
            "system"
        } else {
            i += 1;
            continue;
        };
        let Some(eq) = t.find('=') else {
            i += 1;
            continue;
        };
        let rhs = t[eq + 1..].trim();
        let with_pkgs = rhs.contains("with pkgs;");
        let Some(br) = rhs.find('[') else {
            i += 1;
            continue;
        };
        let after = &rhs[br + 1..];
        let single_line = {
            let mut d = 0;
            let mut closed = false;
            for c in rhs[br..].chars() {
                if c == '[' { d += 1 } else if c == ']' { d -= 1; if d == 0 { closed = true; break; } }
            }
            closed
        };
        if single_line {
            let inner = after.rsplit_once(']').map(|x| x.0).unwrap_or(after);
            let entries = inner
                .split_whitespace()
                .filter(|tok| is_ident(tok.trim_start_matches("pkgs.")))
                .map(|tok| (tok.trim_start_matches("pkgs.").to_string(), i))
                .collect();
            lists.push(PkgList { kind, open_line: i, close_line: i, with_pkgs, single_line, entries });
            i += 1;
            continue;
        }
        let mut depth = depth_delta(&rhs[br..]);
        let mut entries = Vec::new();
        for tok in after.split_whitespace() {
            if depth == 1 && is_ident(tok.trim_start_matches("pkgs.")) {
                entries.push((tok.trim_start_matches("pkgs.").to_string(), i));
            }
        }
        let mut j = i + 1;
        let mut close = None;
        while j < lines.len() {
            let c = strip_comment(lines[j]);
            let ct = c.trim();
            let start_depth = depth;
            depth += depth_delta(ct);
            if start_depth == 1 {
                let body = ct.trim_end_matches(';').trim_end_matches(']').trim();
                if !body.contains(|c| "(){}[]=\";".contains(c)) {
                    for tok in body.split_whitespace() {
                        let name = tok.trim_start_matches("pkgs.");
                        if is_ident(name) {
                            entries.push((name.to_string(), j));
                        }
                    }
                }
            }
            if depth <= 0 {
                close = Some(j);
                break;
            }
            j += 1;
        }
        if let Some(c) = close {
            lists.push(PkgList { kind, open_line: i, close_line: c, with_pkgs, single_line, entries });
            i = c + 1;
        } else {
            i += 1;
        }
    }
    lists
}

fn indent_of(line: &str) -> String {
    line.chars().take_while(|c| *c == ' ' || *c == '\t').collect()
}

fn add_package(text: &str, attr: &str) -> Result<String, String> {
    if !is_ident(attr) {
        return Err(format!("Atributo no válido: {attr}"));
    }
    let lists = find_lists(text);
    let Some(list) = lists.first() else {
        return Err("Este archivo no tiene una lista home.packages ni environment.systemPackages.".into());
    };
    if list.entries.iter().any(|(a, _)| a == attr) {
        return Err(format!("{attr} ya está en este archivo."));
    }
    let mut lines: Vec<String> = text.lines().map(String::from).collect();
    let trailing_nl = text.ends_with('\n');
    let value = if list.with_pkgs { attr.to_string() } else { format!("pkgs.{attr}") };

    if list.single_line {
        let l = &lines[list.open_line];
        let Some(pos) = l.rfind(']') else { return Err("Lista malformada.".into()) };
        let head = l[..pos].trim_end().to_string();
        lines[list.open_line] = format!("{head} {value} {}", &l[pos..]);
    } else {
        let commented = format!("# {attr}");
        let reuse = (list.open_line + 1..list.close_line).find(|&k| {
            let t = lines[k].trim();
            t == commented || t == format!("#{attr}")
        });
        if let Some(k) = reuse {
            let ind = indent_of(&lines[k]);
            lines[k] = format!("{ind}{value}");
        } else {
            let ind = list
                .entries
                .iter()
                .filter(|(_, ln)| *ln > list.open_line)
                .map(|(_, ln)| indent_of(&lines[*ln]))
                .next_back()
                .unwrap_or_else(|| format!("{}  ", indent_of(&lines[list.open_line])));
            let close = &lines[list.close_line];
            let close_trim = close.trim_start();
            if close_trim.starts_with(']') {
                lines.insert(list.close_line, format!("{ind}{value}"));
            } else {
                let pos = close.find(']').unwrap_or(close.len());
                let (before, rest) = close.split_at(pos);
                let before = before.to_string();
                let rest = rest.to_string();
                lines[list.close_line] = before;
                lines.insert(list.close_line + 1, format!("{ind}{value}"));
                lines.insert(list.close_line + 2, format!("{}{}", indent_of(&lines[list.open_line]), rest));
            }
        }
    }
    let mut out = lines.join("\n");
    if trailing_nl {
        out.push('\n');
    }
    Ok(out)
}

fn remove_package(text: &str, attr: &str) -> Result<String, String> {
    let lists = find_lists(text);
    let mut lines: Vec<String> = text.lines().map(String::from).collect();
    let trailing_nl = text.ends_with('\n');
    for list in &lists {
        for (a, ln) in &list.entries {
            if a != attr {
                continue;
            }
            let ln = *ln;
            let line = lines[ln].clone();
            let code = strip_comment(&line);
            let mut tokens = code.split_whitespace().collect::<Vec<_>>();
            let only_this = tokens.len() == 1 && tokens[0].trim_start_matches("pkgs.") == attr;
            if only_this && ln != list.open_line {
                lines.remove(ln);
            } else {
                tokens.retain(|t| t.trim_start_matches("pkgs.") != attr);
                let ind = indent_of(&line);
                let comment = line.find('#').map(|p| format!(" {}", &line[p..])).unwrap_or_default();
                lines[ln] = format!("{ind}{}{comment}", tokens.join(" "));
            }
            let mut out = lines.join("\n");
            if trailing_nl {
                out.push('\n');
            }
            return Ok(out);
        }
    }
    Err(format!("{attr} no está en una lista de paquetes de este archivo."))
}

// ───────────────────────── Comandos ─────────────────────────

fn detect_host(repo: &Path) -> String {
    let flake = fs::read_to_string(repo.join("flake.nix")).unwrap_or_default();
    if let Some(p) = flake.find("nixosConfigurations.") {
        let rest = &flake[p + "nixosConfigurations.".len()..];
        let name: String = rest
            .chars()
            .take_while(|c| c.is_ascii_alphanumeric() || *c == '_' || *c == '-')
            .collect();
        if !name.is_empty() {
            return name;
        }
    }
    "nixos".into()
}

fn detect_channel(repo: &Path) -> String {
    let flake = fs::read_to_string(repo.join("flake.nix")).unwrap_or_default();
    for line in flake.lines() {
        if let Some(p) = line.find("NixOS/nixpkgs/") {
            let rest = &line[p + "NixOS/nixpkgs/".len()..];
            let name: String = rest.chars().take_while(|c| *c != '"' && *c != '?' && !c.is_whitespace()).collect();
            if name == "nixos-unstable" || name == "nixpkgs-unstable" {
                return "unstable".into();
            }
            if let Some(v) = name.strip_prefix("nixos-") {
                return v.to_string();
            }
        }
    }
    String::new()
}

fn cmd_status(repo: &Path) {
    let git = repo.join(".git").exists();
    emit(
        true,
        J::Obj(vec![
            ("repo", s(repo.display().to_string())),
            ("host", s(detect_host(repo))),
            ("channel", s(detect_channel(repo))),
            ("git", J::Bool(git)),
            ("changed", J::Arr(changed_files(repo).into_iter().map(J::Str).collect())),
        ]),
        None,
    );
}

fn changed_files(repo: &Path) -> Vec<String> {
    snapshot_files(repo)
        .into_iter()
        .filter(|rel| {
            let a = fs::read(snap_path(repo, rel)).unwrap_or_default();
            let b = fs::read(repo.join(rel)).unwrap_or_default();
            a != b
        })
        .collect()
}

fn cmd_targets(repo: &Path) {
    let mut files = Vec::new();
    collect_nix_files(repo, repo, &mut files);
    files.sort();
    let mut out = Vec::new();
    for f in files {
        let Ok(text) = fs::read_to_string(&f) else { continue };
        let lists = find_lists(&text);
        if lists.is_empty() {
            continue;
        }
        let first = &lists[0];
        let pkgs: Vec<J> = lists
            .iter()
            .flat_map(|l| l.entries.iter())
            .map(|(a, ln)| J::Obj(vec![("attr", s(a.clone())), ("line", J::Num(ln + 1))]))
            .collect();
        out.push(J::Obj(vec![
            ("file", s(rel_of(repo, &f))),
            ("kind", s(first.kind)),
            ("packages", J::Arr(pkgs)),
        ]));
    }
    emit(true, J::Arr(out), None);
}

fn cmd_files(repo: &Path) {
    let mut files = Vec::new();
    collect_nix_files(repo, repo, &mut files);
    let mut rels: Vec<String> = files.iter().map(|f| rel_of(repo, f)).collect();
    rels.sort();
    emit(true, J::Arr(rels.into_iter().map(J::Str).collect()), None);
}

fn cmd_edit(repo: &Path, rel: &str, attr: &str, adding: bool) {
    let full = match safe_rel(repo, rel) {
        Ok(p) => p,
        Err(e) => return fail(e),
    };
    let text = match fs::read_to_string(&full) {
        Ok(t) => t,
        Err(e) => return fail(e.to_string()),
    };
    let next = if adding { add_package(&text, attr) } else { remove_package(&text, attr) };
    let next = match next {
        Ok(n) => n,
        Err(e) => return fail(e),
    };
    if let Err(e) = snapshot(repo, rel) {
        return fail(e);
    }
    match write_atomic(&full, &next) {
        Ok(()) => emit(true, J::Obj(vec![("file", s(rel)), ("attr", s(attr))]), None),
        Err(e) => fail(e),
    }
}

fn cmd_snapshot(repo: &Path, rel: &str) {
    match snapshot(repo, rel) {
        Ok(()) => emit(true, J::Obj(vec![("file", s(rel))]), None),
        Err(e) => fail(e),
    }
}

fn cmd_diff(repo: &Path) {
    let mut out = String::new();
    for rel in changed_files(repo) {
        let o = Command::new("diff")
            .args(["-u", "--label", &format!("a/{rel}"), "--label", &format!("b/{rel}")])
            .arg(snap_path(repo, &rel))
            .arg(repo.join(&rel))
            .output();
        if let Ok(o) = o {
            out.push_str(&String::from_utf8_lossy(&o.stdout));
        }
    }
    emit(true, s(out), None);
}

fn cmd_revert(repo: &Path) {
    let mut restored = Vec::new();
    for rel in snapshot_files(repo) {
        let src = snap_path(repo, &rel);
        let dst = repo.join(&rel);
        if let Ok(text) = fs::read_to_string(&src) {
            if write_atomic(&dst, &text).is_ok() {
                restored.push(rel);
            }
        }
    }
    let _ = fs::remove_dir_all(snap_dir(repo));
    emit(true, J::Arr(restored.into_iter().map(J::Str).collect()), None);
}

fn cmd_accept(repo: &Path) {
    let _ = fs::remove_dir_all(snap_dir(repo));
    emit(true, J::Obj(vec![]), None);
}

fn print_help() {
    eprintln!(
        "nix-home-installer — backend del instalador\n\n\
Uso:\n  nix-home-installer status [repo]\n  nix-home-installer targets [repo]\n  nix-home-installer files [repo]\n  nix-home-installer add <repo> <archivo.nix> <attr>\n  nix-home-installer remove <repo> <archivo.nix> <attr>\n  nix-home-installer snapshot <repo> <archivo.nix>\n  nix-home-installer diff [repo]\n  nix-home-installer revert [repo]\n  nix-home-installer accept [repo]\n\nTodas las respuestas son JSON en una línea: {{ok, data, error}}."
    );
}

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let cmd = args.first().map(String::as_str).unwrap_or("");
    if cmd.is_empty() || cmd == "help" || cmd == "--help" {
        return print_help();
    }
    let repo = match resolve_repo(args.get(1)) {
        Ok(r) => r,
        Err(e) => return fail(e),
    };
    match cmd {
        "status" => cmd_status(&repo),
        "targets" => cmd_targets(&repo),
        "files" => cmd_files(&repo),
        "diff" => cmd_diff(&repo),
        "revert" => cmd_revert(&repo),
        "accept" => cmd_accept(&repo),
        "snapshot" => match args.get(2) {
            Some(f) => cmd_snapshot(&repo, f),
            None => fail("Falta el archivo."),
        },
        "add" | "remove" => match (args.get(2), args.get(3)) {
            (Some(f), Some(a)) => cmd_edit(&repo, f, a, cmd == "add"),
            _ => fail("Uso: add|remove <repo> <archivo.nix> <attr>"),
        },
        _ => print_help(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = "{ pkgs, ... }:\n\n{\n  home.packages = with pkgs; [\n    # Browsers\n    brave \n    librewolf\n    # alacritty\n    (symlinkJoin { name = \"x\"; paths = [ a ]; })\n    foot # term\n  ];\n}\n";

    #[test]
    fn parses_entries() {
        let l = find_lists(SAMPLE);
        assert_eq!(l.len(), 1);
        let names: Vec<_> = l[0].entries.iter().map(|e| e.0.clone()).collect();
        assert_eq!(names, vec!["brave", "librewolf", "foot"]);
    }

    #[test]
    fn adds_and_uncomments() {
        let a = add_package(SAMPLE, "vivaldi").unwrap();
        assert!(a.contains("    foot # term\n    vivaldi\n  ];"));
        let b = add_package(SAMPLE, "alacritty").unwrap();
        assert!(b.contains("\n    alacritty\n"));
        assert!(add_package(SAMPLE, "brave").is_err());
    }

    #[test]
    fn removes() {
        let r = remove_package(SAMPLE, "librewolf").unwrap();
        assert!(!r.contains("librewolf"));
        let r = remove_package(SAMPLE, "foot").unwrap();
        assert!(r.contains("\n    # term\n") || !r.contains("foot"));
        assert!(remove_package(SAMPLE, "nope").is_err());
    }

    #[test]
    fn no_with_pkgs_prefixes() {
        let s = "{\n  environment.systemPackages = [\n    pkgs.git\n  ];\n}\n";
        let a = add_package(s, "htop").unwrap();
        assert!(a.contains("    pkgs.htop\n"));
    }

    #[test]
    fn single_line() {
        let s = "{ home.packages = with pkgs; [ git ]; }\n";
        let a = add_package(s, "htop").unwrap();
        assert!(a.contains("[ git htop ]"));
    }
}
