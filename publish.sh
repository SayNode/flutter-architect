dart compile exe lib/architect.dart -o npm/architect.exe;
cd npm;
npm login;
npm version patch;
npm publish;