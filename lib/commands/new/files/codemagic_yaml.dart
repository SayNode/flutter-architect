String content() {
  return """
workflows:
  android-workflow:
    name: Development Android Workflow
    instance_type: mac_mini_m1
    max_build_duration: 60
    environment:
      android_signing:
        - welshare_android_keystore # <- modify this to your keystore reference
      groups:
        - backend_keys 
        - google_credentials # <-- (Includes GCLOUD_SERVICE_ACCOUNT_CREDENTIALS)
      vars:
        PACKAGE_NAME: "health.welshare.app" # <-- Put your package name here
        GOOGLE_PLAY_TRACK: "internal"
        CM_CLONE_DEPTH: 5
      flutter: stable
      java: 17
    triggering:
      events:
        - tag
      tag_patterns:
        - pattern: '*-dev'
    scripts:
      - name: Generating release notes with git commits
        script: |
          git fetch --all --tags
          prev_tag=\$(git for-each-ref --sort=-creatordate  --format '%(objectname)' refs/tags | sed -n 2p )
          notes+=\$(git log --pretty=format:"\n %s" "\$prev_tag"..HEAD)
          echo "\$notes" | tee release_notes.txt
      - name: Set up local.properties
        script: |
          echo "flutter.sdk=\$HOME/programs/flutter" > "\$CM_BUILD_DIR/android/local.properties"
      - name: Get Flutter packages
        script: |
          flutter packages pub get
        ignore_failure: true
      - name: Build AAB with Flutter
        script: |
          BUILD_NUMBER=\$PROJECT_BUILD_NUMBER + 1
          flutter build appbundle --release \\
            --no-tree-shake-icons \\
            --build-name=1.3.\$PROJECT_BUILD_NUMBER + 1 \\
            --build-number=\$BUILD_NUMBER \\
            --dart-define=API_URL=\$API_URL_DEV \\
    artifacts:
      - build/**/outputs/**/*.aab
      - build/**/outputs/**/mapping.txt
      - flutter_drive.log
      - release_notes.txt
    publishing:
      email:
        recipients:
          - francesco@saynode.ch
          - yann@saynode.ch
          - manuel@saynode.ch
          - ruthu@saynode.ch
          - gabriela@saynode.ch
          - julian@saynode.ch
          - werner@saynode.ch
          - renato@saynode.ch
          - paula@saynode.ch
        notify:
          success: true
          failure: true
      google_play:
        credentials: \$GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        submit_as_draft: true
  ios-workflow:
    name: Development iOS Workflow
    instance_type: mac_mini_m1
    max_build_duration: 60
    integrations:
      app_store_connect: Welshare CI/CD # <- put here the team label key (can find this in codemagic)
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: health.welshare.app # <- put bundle identifier here // io.codemagic.flutteryaml
      groups:
        - backend_keys 
      vars:
        APP_ID: 6478221862 # <-- Put your APP ID here
        CM_CLONE_DEPTH: 5
      flutter: stable
      xcode: latest # <-- set to specific version e.g. 14.3, 15.0 to avoid unexpected updates.
      cocoapods: default
    triggering:
      events:
        - tag
      tag_patterns:
        - pattern: '*-dev'
    scripts:
      - name: Generating release notes with git commits
        script: | 
          git fetch --all --tags
          prev_tag=\$(git for-each-ref --sort=-creatordate  --format '%(objectname)' refs/tags | sed -n 2p )
          notes+=\$(git log --pretty=format:"\n %s" "\$prev_tag"..HEAD)
          echo "\$notes" | tee release_notes.txt
      - name: Set up code signing settings on Xcode project
        script: |
          xcode-project use-profiles
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Flutter build ipa and automatic versioning
        script:  |
          flutter pub get
          cd ios
          pod repo update
          pod update
          appversion = \$PROJECT_BUILD_NUMBER
          echo "version from store \${appversion}"
          flutter build ipa --release \\
            --build-name=1.1.\$PROJECT_BUILD_NUMBER + 1 \\
            --build-number=\$PROJECT_BUILD_NUMBER + 1 \\
            --dart-define=API_URL=\$API_URL_DEV \\
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
      - release_notes.txt
    publishing:
      email:
        recipients:
          - francesco@saynode.ch
          - yann@saynode.ch
          - manuel@saynode.ch
          - ruthu@saynode.ch
          - gabriela@saynode.ch
          - julian@saynode.ch
          - werner@saynode.ch
          - renato@saynode.ch
          - paula@saynode.ch
        notify:
          success: true
          failure: true
      app_store_connect:
        auth: integration
        # Configuration related to TestFlight (optional)
        # Note: This action is performed during post-processing.
        submit_to_testflight: true
        # Configuration related to App Store (optional)
        # Note: This action is performed during post-processing.
        submit_to_app_store: false

  ########################################
  #
  #     PRODUCTION
  #
  ########################################

  android-workflow-production:
    name: Production Android Workflow
    instance_type: mac_mini_m1
    max_build_duration: 60
    environment:
      android_signing:
        - welshare_android_keystore # <- modify this to your keystore reference
      groups:
        - google_credentials # <-- (Includes GCLOUD_SERVICE_ACCOUNT_CREDENTIALS)
        - backend_keys
      vars:
        PACKAGE_NAME: "health.welshare.app" # <-- Put your package name here
        GOOGLE_PLAY_TRACK: "internal"
        CM_CLONE_DEPTH: 5
      flutter: stable
      java: 17
    triggering:
      events:
        - tag
      tag_patterns:
        - pattern: '*-prod'
    scripts:
      - name: Generating release notes with git commits
        script: |
          git fetch --all --tags
          prev_tag=\$(git for-each-ref --sort=-creatordate  --format '%(objectname)' refs/tags | sed -n 2p )
          notes+=\$(git log --pretty=format:"\n %s" "\$prev_tag"..HEAD)
          echo "\$notes" | tee release_notes.txt
      - name: Set up local.properties
        script: |
          echo "flutter.sdk=\$HOME/programs/flutter" > "\$CM_BUILD_DIR/android/local.properties"
      - name: Get Flutter packages
        script: |
          flutter packages pub get
        ignore_failure: true
      - name: Build AAB with Flutter
        script: |
          BUILD_NUMBER=\$PROJECT_BUILD_NUMBER + 1
          flutter build appbundle --release \\
            --build-name=1.3.\$PROJECT_BUILD_NUMBER + 1 \\
            --build-number=\$BUILD_NUMBER \\
            --dart-define=API_URL=\$API_URL_PROD \\
    artifacts:
      - build/**/outputs/**/*.aab
      - build/**/outputs/**/mapping.txt
      - flutter_drive.log
      - release_notes.txt
    publishing:
      email:
        recipients:
          - francesco@saynode.ch
          - yann@saynode.ch
          - manuel@saynode.ch
          - ruthu@saynode.ch
          - gabriela@saynode.ch
          - julian@saynode.ch
          - werner@saynode.ch
          - renato@saynode.ch
          - paula@saynode.ch
        notify:
          success: true
          failure: true
      google_play:
        credentials: \$GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        submit_as_draft: true
  ios-workflow-production:
    name: Production iOS Workflow
    instance_type: mac_mini_m1
    max_build_duration: 60
    integrations:
      app_store_connect: Welshare CI/CD
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: health.welshare.app # <- put bundle identifier here // io.codemagic.flutteryaml
      groups:
        - backend_keys
      vars:
        APP_ID: 6478221862 # <-- Put your APP ID here
        CM_CLONE_DEPTH: 5
      flutter: stable
      xcode: latest # <-- set to specific version e.g. 14.3, 15.0 to avoid unexpected updates.
      cocoapods: default
    triggering:
      events:
        - tag
      tag_patterns:
        - pattern: '*-prod'
    scripts:
      - name: Generating release notes with git commits
        script: |
          git fetch --all --tags
          prev_tag=\$(git for-each-ref --sort=-creatordate  --format '%(objectname)' refs/tags | sed -n 2p )
          notes+=\$(git log --pretty=format:"\n %s" "\$prev_tag"..HEAD)
          echo "\$notes" | tee release_notes.txt
      - name: Set up code signing settings on Xcode project
        script: |
          xcode-project use-profiles
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Flutter build ipa and automatic versioning
        script: |
          flutter pub get
          cd ios
          pod repo update
          pod update
          flutter build ipa --release \\
            --build-name=1.1.\$PROJECT_BUILD_NUMBER + 1 \\
            --build-number=\$PROJECT_BUILD_NUMBER + 1 \\
            --dart-define=API_URL=\$API_URL_PROD \\
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
      - release_notes.txt
    publishing:
      email:
        recipients:
          - francesco@saynode.ch
          - yann@saynode.ch
          - manuel@saynode.ch
          - ruthu@saynode.ch
          - gabriela@saynode.ch
          - julian@saynode.ch
          - werner@saynode.ch
          - renato@saynode.ch
          - paula@saynode.ch
        notify:
          success: true
          failure: true
      app_store_connect:
        auth: integration
        submit_to_testflight: true
        submit_to_app_store: false

""";
}
