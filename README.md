[![version](https://img.shields.io/badge/docker@latest-1.3.1-blue?style=flat)](https://github.com/users/JasonTheDeveloper/packages/container/package/code-monkeys)
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

This repository contains the code-monkey agent configuration and devcontainer-feature installer. This feature will copy [agent files](./devcontainer-feature/code-monkey/agents/) to `.github/agents/` and OWSAP vulnerability [skills](./devcontainer-feature/code-monkey/skills/) to `.github/skills/` in the root of your project.

## Example Usage

```json
"features": {
    "ghcr.io/jasonthedeveloper/code-monkeys/code-monkey:1": {
        "replaceExisting": false,
        "agent": true,
        "skills": true
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| replaceExisting | Replace existing agent and skill files if they already exist in the workspace | boolean | false |
| agent | Copy the Code Monkey agent file to .github/agents/ in the workspace | boolean | true |
| skills | Copy skill files to .github/skills/ in the workspace | boolean | true |
