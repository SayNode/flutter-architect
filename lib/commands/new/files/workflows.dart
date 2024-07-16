String lintingWorkflow = """


name: Linting Workflow

on: pull_request

jobs:
  build:
    name: Linting
    runs-on: ubuntu-latest
    steps:
      - name: Setup Repository
        uses: actions/checkout@v2

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter --version

      - name: Install Pub Dependencies
        run: flutter pub get

      - name: Verify Formatting
        run: dart format --output=none --set-exit-if-changed .
      - name: Analyze Project Source
        run: dart analyze --fatal-infos
""";

String prAgent = r'''
on:
  pull_request:
  issue_comment:
jobs:
  pr_agent_job:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      pull-requests: write
      contents: write
    name: Run pr agent on every pull request, respond to user comments
    steps:
      - name: PR Agent action step
        id: pragent
        uses: Codium-ai/pr-agent@main
        env:
          OPENAI_KEY: ${{ secrets.OPENAI_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
''';
