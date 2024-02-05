String content() {
  return """
workflows:
  android-workflow:
    name: Development Android Workflow
    instance_type: mac_mini_m1
    max_build_duration: 60
    environment:
      android_signing:
        - legacy_wallet_android_keystore # <- modify this to your keystore reference DONE
      groups:
        - legacy_wallet_variables # <-- (Includes GCLOUD_SERVICE_ACCOUNT_CREDENTIALS) DONE
      vars:
        PACKAGE_NAME: "io.legacynetwork.app" # <-- Put your package name here DONE
        GOOGLE_PLAY_TRACK: "internal"
        CM_CLONE_DEPTH: 5
      flutter: stable
      java: 17
    triggering:
      events:
        - tag
    scripts:
      - name: Generating release notes with git commits
        script: |
          git fetch --all --tags
          prev_tag=\$(git for-each-ref --sort=-creatordate  --format '%(objectname)' refs/tags | sed -n 2p )
          notes="{["text":"
          notes+=\$(git log --pretty=format:"%s," "\$prev_tag"..HEAD)
          notes+="]}"
          echo "\$notes"
          echo "\$notes" | tee release_notes.json
      - name: Set up local.properties
        script: |
          echo "flutter.sdk=\$HOME/programs/flutter" > "\$CM_BUILD_DIR/android/local.properties"
      - name: Get Flutter packages
        script: |
          flutter packages pub get
        #      - name: Flutter analyze # to add only to the PR pipeline
        #        script: |
        #          flutter analyze
        #      - name: Flutter unit tests
        #        script: |
        #          flutter test
        ignore_failure: true
      - name: Build AAB with Flutter
        #          update the followin command with the correct configuration for the app
        #          and create all the required env variables in the codemagic project
        script: |
          BUILD_NUMBER=\$((\$PROJECT_BUILD_NUMBER + 400))
          flutter build appbundle --release 
            --no-tree-shake-icons 
            --build-name=1.3.\$((\$PROJECT_BUILD_NUMBER + 10)) 
            --build-number=\$BUILD_NUMBER 
            --dart-define=DATABASE_URL=api-dev.skillbuddy.io 
            --dart-define=DATABASE_API_KEY=\$DATABASE_API_KEY_DEV_ENV 
    artifacts:
      - build/**/outputs/**/*.aab
      - build/**/outputs/**/mapping.txt
      - flutter_drive.log
      - release_notes.json
    publishing:
      email:
        recipients:
          - francesco@saynode.ch
          - yann@saynode.ch
          - manuel@saynode.ch
          - ruthu@saynode.ch
          - gabriela@saynode.ch
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
      app_store_connect: Legacy CI/CD # <- put here the team label key (can find this in codemagic) DONE
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: io.legacynetwork.app # <- put bundle identifier here // io.codemagic.flutteryaml DONE
      vars:
        APP_ID: 6443578674 # <-- Put your APP ID here DONE
        CM_CLONE_DEPTH: 5
      flutter: stable
      xcode: latest # <-- set to specific version e.g. 14.3, 15.0 to avoid unexpected updates.
      cocoapods: default
    triggering:
      events:
        - tag
    scripts:
      - name: Generating release notes with git commits
        script: |
          git fetch --all --tags
          prev_tag=\$(git for-each-ref --sort=-creatordate  --format '%(objectname)' refs/tags | sed -n 2p )
          notes=\$(git log --pretty=format:"\n- %s" "\$prev_tag"..HEAD)
          notes="{["text":"
          notes+=\$(git log --pretty=format:"%s," "\$prev_tag"..HEAD)
          notes+="]}"
          echo "\$notes"
          echo "{\$notes}" | tee release_notes.json
      - name: Set up code signing settings on Xcode project
        script: |
          xcode-project use-profiles
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Install pods
        script: |
          find . -name "Podfile" -execdir pod install ;
      #      - name: Flutter analyze
      #        script: |
      #          flutter analyze
      #      - name: Pod update
      #        script: |
      #          cd ios
      #          pod repo update
      #          pod update
      #          cd ..
      #      - name: Flutter unit tests
      #        script: |
      #          flutter test
      #        ignore_failure: true
      - name: Flutter build ipa and automatic versioning
      #          update the followin command with the correct configuration for the app
      #          and create all the required env variables in the codemagic project
        script: |
          flutter pub get
          cd ios
          pod repo update
          pod update
          appversion = \$PROJECT_BUILD_NUMBER
          echo "version from store \${appversion}"
          flutter build ipa --release 
            --no-tree-shake-icons 
            --build-name=1.3.\$((\$PROJECT_BUILD_NUMBER + 10)) 
            --build-number=\$((\$PROJECT_BUILD_NUMBER + 10)) 
            --dart-define=DATABASE_URL=api-dev.skillbuddy.io 
            --dart-define=DATABASE_API_KEY=\$DATABASE_API_KEY_DEV_ENV 
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
      - release_notes.json
    publishing:
      # See the following link for details about email publishing - https://docs.codemagic.io/publishing-yaml/distribution/#email
      email:
        recipients:
          - francesco@saynode.ch
          - yann@saynode.ch
          - manuel@saynode.ch
          - ruthu@saynode.ch
          - gabriela@saynode.ch
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
""";
}
