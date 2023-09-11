How to update to newer OpenSSL version, build, and publish a release.

1. **Clone this repository.**

   ```shell
   git clone https://github.com/cossacklabs/openssl-apple
   ```

   Make sure you're on the `cossacklabs` branch.

2. **Update OpenSSL version.**

   The version number is in the [`Makefile`](Makefile).

   Increment `PACKAGE_VERSION` if you are repackaging the same OpenSSL version.
   Otherwise, update `VERSION` to OpenSSL version and reset `PACKAGE_VERSION` to `1`.

   ```
   ## OpenSSL version to build
   VERSION ?= 1.1.1v
   ## Extra version of the distributed package
   PACKAGE_VERSION ?= 1
   ```

   Also update tarball checksums in [`build-libssl.sh`](build-libssl.sh).
   ```
   # Default version in case no version is specified
   # Official checksums available at https://www.openssl.org/source/
   DEFAULTVERSION="1.1.1u"
   OPENSSL_CHECKSUMS="
   1.1.1k 892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5
   1.1.1u e2f8d84b523eecd06c7be7626830370300fbcc15386bf5142d72758f6963ebc6
   1.1.1v d6697e2871e77238460402e9362d47d18382b15ef9f246aba6c7bd780d38a6b0
   "
   ```

3. **Update platform configuration.**

   Things like minimum OS SDK versions, architectures, etc.
   You can find all this in the [`Makefile`](Makefile).

4. **Build OpenSSL.**

   To build from scratch - remove output folder.

   ```shell
   make clean && make
   ```

   This can take a while.
   Not only it builds the library, this also packages it,
   and updates the project specs.

   Check the cocoapods/CLOpenSSL-XCF.podspec. It have to be created from podpec.template file with actual version, hash and filenames.

   Note: semversioned number of framework is taken from ```frameworks/MacOSX/openssl.framework```.


5. **Update SPM package settings**

	 Update [`Package.swift`](Package.swift) file with the new URL of the binary framework and its checksum:

   ```swift
   .binaryTarget(name: "openssl",
              // update version in URL path
              url:"https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12201/openssl-static-xcframework.zip",
              // Run from package directory:
              // swift package compute-checksum output/openssl-static-xcframework.zip
              checksum: "a3363e4297428d2497c481791f6ac3c17c118b6829ee6246781efe0a3593ae16"),
   ```
   Remember: actual version you can see in output/version file. It is created by authors of the OpenSSL library.

6. **Update the Carthage package settings and prepare the copy of files**
   During the 'make' process, the scripts in the 'scripts' folder had to update the json files in the carthage folder. Check it out.

   `cat carthage/openssl-dynamic-framework.json`
   ```
   {
    "1.1.12201": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12201/openssl-dynamic-xcframework.zip",
    "1.1.12101": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12101/openssl-dynamic-xcframework.zip",
    "1.1.11101": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.11101/openssl-dynamic-xcframework.zip",
    "1.1.10803": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.10803/openssl-dynamic-xcframework.zip",
   }
   ```

   `cat carthage/openssl-static-framework.json`
   ```
   rad@Oleksiis-M1-2021 ~/g/p/t/openssl-apple (openssl-1.1.1v)> cat carthage/openssl-static-xcframework.json
   {
    "1.1.12201": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12201/openssl-static-xcframework.zip",
    "1.1.12101": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12101/openssl-static-xcframework.zip",
    "1.1.11101": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.11101/openssl-static-xcframework.zip",
    "1.1.10803": "https://github.com/cossacklabs/openssl-apple/releases/download/1.1.10803/openssl-static-xcframework.zip",
   }
   ```

   Also carthage will use files with the name that contain ".xcframework". So, you need to copy files in output directory to corresponding names.
   `openssl-dynamic-xcframework.zip` to `openssl-dynamic.xcframework.zip`.
   And `openssl-static-xcframework.zip` to `openssl-static.xcframework.zip`
   You will upload these files later into the release.

7. **Cocoapods podspec**
   During the 'make' process scripts had to generate new podspec file from the template located in 'cocoapods' directory.
   So, you will see the new file: CLOpenSSL-XCF.podspec
   Check it out. You have to see newly created version and hash checksum in the body of the file.
   ```
   openssl_version = "1.1.12201"
   XCFramework_archive_hash = "bc9d20b7e4369b3cec2f30115e455f610c9d61aefc569676805b006d83e77944"
   ```

   You can compare the hash with the result of command `swift package compute-checksum output/openssl-dynamic-xcframework.zip`
   It should be equal.
   openssl_version have to be equal to `cat output/version`

8. **Commit, tag, push the release.**

   Commit the changes. Changes must contain new version settings, SPM, Carthage, and Cocoapods updates. Optionally, other files.

   Tag should be in a semver format. Do not add cocoapods/CLOpenSSL-XCF.podspec to the git. It is generated every time.

   ```shell
   git add carthage
   git add Package.swift
   git commit -S -e -m "OpenSSL 1.1.1v"
   git tag -s -e -m "OpenSSL 1.1.1v" 1.1.12201
   git push origin cossacklabs # Push the branch
   git push origin 1.1.12201  # Push the tag
   ```

   Make will remind you how to do this.
   (Use the correct versions there.)
   Take care to make signed commits and tags, this is important for vanity.

   Congratulations!
   You have just published broken Carthage and SPM packages :)

9. **Publish GitHub release with binary framework files.**

   Go to GitHub release page for the tag:

   https://github.com/cossacklabs/openssl-apple/releases/tag/1.1.12201

   press **Edit tag** and upload `*.zip` packages from `output` directory. Do not forget to upload also .xcframework.zip files too. It is important for carthage binary prebuilt scheme.

   Also, describe the release, press the **Publish release** when done.

   Congratulations!
   You should have fixed the Carthage and SPM packages with this.

10. **Publish podspec.**

   ```shell
   pod spec lint
   pod trunk push cocoapods/CLOpenSSL-XCF.podspec
   ```

   This lints the podspec before publishing it.
   If it does not lint then curse at CocoaPods and scrub the release.

   Congratulations!
   You have published a CocoaPods package.

Actually, you have published all of the OpenSSL.
Now is the time to go check if it *actually* works.

You can use [Themis](https://github.com/cossacklabs/themis) for that.

11. **Test the CLOpenSSL-XCF release**

   ##### SPM

  1. Create a new Xcode project.
  2. Add the package from the URL: https://github.com/cossacklabs/openssl-apple
  3. Select the exact version (Which you released recently)
  4. Compile and run project (Build, Archive)

   ##### Carthage
  1. Create a new Xcode project
  2. Create Cartfile near the .xcodeproj or .xcworkspace file
  3. Add similar content
  ```
  “github "cossacklabs/openssl-apple" ~> 1.1.12201
  ```

  Run

  ```
  carthage update --use-xcframeworks
  ```

  4. Drag the downloaded `.xcframework` bundles from `Carthage/Build` into the "Frameworks and Libraries" section of your application’s Xcode project.

  ##### Cocoapods
  1. Create new Xcode project
  2. run pod init from the root of the project
  3. Add

      ```bash
      pod 'CLOpenSSL-XCF'
      ```

  4. Run

      ```bash
      pod install
      ```

      Open .xcworkspace file and run test the project


