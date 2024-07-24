# Flutter Architect

Flutter Architect is an open-source bootstrap CLI for Flutter project initialisation, distributed via NPM (Node Package Manager). It supports the generation of multiple boilerplate features. You are welcome to contribute with features and components yo udeem useful.

You can use this tool to generate Flutter projects for all platforms, but keep in mind that some components might be exclusive to Android and iOS.

To install the CLI, open a terminal and enter the following command.

```bash
npm install -g flutter-architect 
```

> ## Commands

Let's make an effort of keeping this list of commands updated as the project evolves.

> ### Project Creation

To create a project, navigate to the desired location and use the following command.

```bash
architect new --name=<project_name> --ios --android <other_platforms> --org=<package_organization>
# Note that a package organization is required.
```

> ### Component Addition

These are the commands available to add components to your project. It only makes sense to add components to a project freshly generated with this tool.
You can always use the help command to find assistance.

```bash
architect generate --help
```

> #### **API and Authentication**

Adds a service to handle a third-party API, as well as an higher level authentication service.

```bash
architect generate api
```

> #### **Platform Signin Options**

Complements the authentication service with platform-specific signin options.

```bash
architect generate signin --apple --google
# You can choose to only add the Google option or only the Apple option.
```

> #### **Connectivity**

Adds a service to handle connectivity events.

```bash
architect generate connectivity
```

> #### **Crashlytics**

Sets up Firebase, and adds Crashlytics logging.

```bash
architect generate crashlytics
```

> #### **Localization**

Prepares the app to handle localization.

```bash
architect generate localization
```

> #### **Native Splash Screen**

Creates the native splash screen for the platforms the project has been initialized for.

```bash
architect generate splash
```

> #### **Local Storage**

Creates both a secure storage service and a shared storage service.

```bash
architect generate storage
```

> #### **Local Storage**

Creates both a secure storage service and a shared storage service.

```bash
architect generate storage
```

> #### **Theme**

Imports the theme settings and colors from a Figma project.

```bash
architect generate theme
```

> #### **Typography**

Imports the typography from a Figma project.

```bash
architect generate typography
```

> #### **Upgrader**

Creates an upgrader service to manage app versioning.

```bash
architect generate upgrader
```

> #### **Wallet**

Adds web3 wallet integration.

```bash
architect generate wallet
```

> #### **Page**

Create a page, according to the MVC (Model-View-Controller) arquitecture.

```bash
architect generate page --name Home
# The "name" parameter should be in Pascal Case.
```

Additionally, you can use the parameters "--force" or "--remove".

> ## How to setup the tool for local development

> ### *Temporary setup*

Use Git Bash to run the following commands. If you're using VSCode, open View > Terminal (Ctrl+`). Click on the dropdown arrow next to the + icon in the terminal panel to pick a new shell to open. If Git Bash is installed, it will be shown in the list.

```bash
dart compile exe lib/architect.dart -o architect.exe
alias architect-dev="./architect.exe"  
```

You can also use the absolute path.

```bash
alias architect-dev="/Users/saynode/Documents/GitHub/flutter-architect/architect.exe"
# "/Users/saynode/Documents/GitHub/flutter-architect/" is an example path, and likely not the same as yours.
```

We recommend using the alias "architect-dev", so that it doesn't interfere with any live versions of the Architect instaleld through NPM.

> ### *Permanent setup*

On Mac and Linux add the following to your .bashrc file

```bash
    alias architect="*absolute path to exe*"
```

On windows edit the aliases file in C:\Program Files\Git\etc\profile.d\aliases.sh (as administrator)

```bash
    alias architect="*absolute path to exe*"
```
