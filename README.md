[![version](https://img.shields.io/badge/docker@latest-1.0.0-blue?style=flat)](https://github.com/users/JasonTheDeveloper/packages/container/package/code-monkeys)
[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

<pre style="background: transparent">
 ██████╗ ██████╗ ██████╗ ███████╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║     ██║   ██║██║  ██║█████╗
██║     ██║   ██║██║  ██║██╔══╝
╚██████╗╚██████╔╝██████╔╝███████╗
 ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

███╗   ███╗ ██████╗ ███╗   ██╗██╗  ██╗███████╗██╗   ██╗
████╗ ████║██╔═══██╗████╗  ██║██║ ██╔╝██╔════╝╚██╗ ██╔╝
██╔████╔██║██║   ██║██╔██╗ ██║█████╔╝ █████╗   ╚████╔╝
██║╚██╔╝██║██║   ██║██║╚██╗██║██╔═██╗ ██╔══╝    ╚██╔╝
██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║  ██╗███████╗   ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝   ╚═╝
</pre>

This repository contains the code-monkey agent configuration and devcontainer-feature installer. This feature will copy [code-monkey.md](./devcontainer-feature/code-monkey/code-monkey.md) to `.github/agents/` in the root of your project.

## Example Usage

```json
"features": {
    "ghcr.io/jasonthedeveloper/code-monkeys/code-monkey:1": {}
}
```
