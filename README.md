

TODO:

Add selection for what devices should run the app eg. android, ios, windows

*How to setup the tool temporarily*

Use GitBash to run the following commands:

```bash

dart compile exe lib/project_initialization_tool.dart -o generator.exe
alias generator="./generator.exe"
    
```


*How to setup the tool permanently*

On mac and linux add the following to your .bashrc file

```bash
    alias generator="*absolute path to exe*"
```

On windows edit the aliases file in C:\Program Files\Git\etc\profile.d\aliases.sh

```bash
    alias generator="*absolute path to exe*"
```