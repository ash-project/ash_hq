// Builds the Installer page's install command. No DOM access, so it can be tested on its own
// (tests/installer/command_test.js checks it against the Phoenix app's installer).
//
// The command is built as the Phoenix app's installer built it (`setUrl` in its app.js), so the
// commands people copy are unchanged.
//
// features:      { key: { adds, args, requires, checked } }, `checked` being what was picked
// installOrder:  feature keys in the order they're installed
// mode:          "new" or "existing"
// installElixir: for new projects, whether the command installs Elixir first
// appName:       the project name as typed
// phoenixVersion: the latest phx_new, for installing Phoenix's generator directly
// baseUrl:       where the site is served, such as "https://ash-hq.org", for the curl command

// Features picked, with the features they require
export function selection(features, installOrder) {
  const selected = new Set();
  for (const key of installOrder) {
    if (!features[key].checked) continue;
    features[key].requires.forEach((requirement) => selected.add(requirement));
    selected.add(key);
  }
  return selected;
}

export function safeAppName(name) {
  return name
    .replace(/[^a-zA-Z0-9\s_-]/g, "")
    .replace(/[\s-_]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/^(\d)/, "app_$1")
    .toLowerCase();
}

export function buildCommand({ features, installOrder, mode, installElixir, appName, phoenixVersion, baseUrl }) {
  let args = [];
  let packages = ["ash"];

  for (const key of installOrder) {
    const feature = features[key];
    if (!feature.checked) continue;

    for (const requirement of feature.requires) {
      packages.push(...features[requirement].adds);
      args.push(...features[requirement].args);
    }
    packages.push(...feature.adds);
    args.push(...feature.args);
  }

  packages = [...new Set(packages)];
  args = [...new Set(args)];

  const app = safeAppName(appName);
  const selected = selection(features, installOrder);
  const has = (key) => selected.has(key);

  let installArg = "";
  if (has("phoenix")) {
    installArg = "?install=phoenix";
    if (has("postgres")) {
      // The default database
    } else if (has("sqlite")) {
      installArg += "&with_args=--database%20sqlite3";
    } else {
      installArg += "&with_args=--no-ecto";
    }
  }

  let code;
  let limit;

  if (mode === "existing") {
    code = "mix igniter.install ";
    limit = 45;
  } else if (installElixir) {
    code = `sh <(curl '${baseUrl}/install/${app}${installArg}')`;
    if (packages.length !== 0) packages.unshift("&& mix igniter.install");
    packages.unshift(`&& cd ${app}`);
    limit = Math.max(code.length - 2, 45);
  } else {
    // Elixir is already installed: install the generators and run igniter.new directly
    limit = 75;
    const lines = ["mix archive.install hex igniter_new --force"];
    if (has("phoenix") && phoenixVersion) {
      lines.push(`mix archive.install hex phx_new ${phoenixVersion} --force`);
    }
    lines.push("");

    const parts = [`mix igniter.new ${app}`];
    if (has("phoenix")) {
      parts.push("--with phx.new");
      if (has("postgres")) {
        // The default database
      } else if (has("sqlite")) {
        parts.push('--with-args "--database sqlite3"');
      } else {
        parts.push('--with-args "--no-ecto"');
      }
    }
    for (let i = 0; i < packages.length; i += 2) {
      parts.push(`--install ${packages.slice(i, i + 2).join(",")}`);
    }
    parts.push(...args, "--setup", "--yes");

    let line = parts[0];
    for (const part of parts.slice(1)) {
      if ((line + " " + part).length > limit) {
        lines.push(line + " \\");
        line = "  " + part;
      } else {
        line += " " + part;
      }
    }
    lines.push(line);
    return lines.join("\n").trim();
  }

  // The curl and existing app commands, wrapped as the Phoenix app wrapped them
  packages.push(...args, "--setup");
  if (args.length !== 0 || packages.length !== 0) packages.push("--yes");

  let line = code;
  code = "";
  for (const item of packages) {
    if ((line + item).length > limit) {
      code += `\n    ${line.trim()} \\`;
      line = "";
    }
    line += item + " ";
  }
  if (line.trim().length > 0) code += `\n    ${line.trim()}`;

  return code.trim();
}
