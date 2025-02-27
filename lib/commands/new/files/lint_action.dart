String content() {
  return """
 
 
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
        run: dart analyze --fatal-infos""";
}
