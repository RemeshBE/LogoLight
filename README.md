# LogoLight

LogoLight is a native macOS menu bar app for controlling the illuminated Apple logo on compatible MacBook Pro models with a PROLED XDR display.

## Features

- Turn the logo on or off from the menu bar, or pause it for 15 minutes, one hour or until tomorrow.
- Set daily and weekend schedules, with an optional sunset-based start time.
- Turn lighting off on battery power or while connected to a chosen Wi-Fi network.
- Show an optional countdown during temporary pauses.
- Set up Apple Shortcuts with the in-app guide and copyable URLs.
- Use the app in English, Dutch, French, German or Spanish.

## Compatibility and permissions

The installer checks for Mac17,10, Mac17,11, Mac17,12 or Mac17,13. The lighting preference affects all users on the Mac. Installing the lighting service requires administrator approval. Wi-Fi rules may require Location Services permission to read the connected network name. Preferences are saved locally.

Keep LogoLight running in the menu bar for schedules and automation. Closing the main window leaves the app running. Choose **Open LogoLight** from the menu bar to reopen it.

[Apple Support: about the illuminated Apple logo](https://support.apple.com/en-us/149248)

## Build a local test package

On an Apple silicon Mac with the Apple developer tools installed, run:

```sh
bash package.sh
```

The installer is written to `build/LogoLight-25.2.pkg`. This is a local test build. The package script uses ad-hoc signing for the app, and the installer itself is unsigned.

## Public releases

For public distribution, sign both the app and its lighting service with Developer ID Application and enable hardened runtime. Sign the installer with Developer ID Installer, submit the finished package for notarization, then staple and verify the ticket. Test a fresh download on compatible hardware before adding it to GitHub Releases.

[Apple: Packaging Mac software for distribution](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution)

Made with the help of AI by RemeshBE.

## If macOS blocks the test installer

I don’t yet have an Apple Developer Program membership. The test installer is unsigned and hasn’t been notarized, so macOS may say Apple couldn’t verify the package. Use the following steps only if you trust the source and are sure the download hasn’t been altered.

1. Double-click the LogoLight `.pkg` in Finder. If the warning appears, click **Done**.
2. In **System Settings**, open **Privacy & Security** and scroll down to **Security**.
3. Find the message about the LogoLight package and click **Open Anyway**. macOS normally shows this option for about one hour after the blocked attempt.
4. Confirm the prompt and authenticate if asked. In Installer, follow the steps and approve the installation of the lighting service.

This exception applies to the package you chose. On a managed Mac, your IT administrator may restrict this option.

[Apple Support: Safely open apps on your Mac](https://support.apple.com/en-us/102445)
