

TODO:

Add selection for what devices should run the app eg. android, ios, windows

*How to setup the tool temporarily*

Use Git Bash to run the following commands. If you're using VSCode, open View > Terminal (Ctrl+`). Click on the dropdown arrow next to the + icon in the terminal panel to pick a new shell to open. If Git Bash is installed, it will be shown in the list.

```bash

dart compile exe lib/architect.dart -o architect.exe
alias architect="./architect.exe"
    
```

or with full path

```bash
alias architect="/Users/saynode/Documents/GitHub/flutter-architect/architect.exe"
```

"/Users/saynode/Documents/GitHub/flutter-architect/" is an example and is probably not the same as yours.

*How to setup the tool permanently*

On Mac and Linux add the following to your .bashrc file

```bash
    alias architect="*absolute path to exe*"
```

On windows edit the aliases file in C:\Program Files\Git\etc\profile.d\aliases.sh (as administrator)

```bash
    alias architect="*absolute path to exe*"
```
