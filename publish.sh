dart compile exe lib/architect.dart -o npm/architect.exe;
cp README.md npm;
cd npm;
npm login;
npm version patch;
npm publish --access=public;