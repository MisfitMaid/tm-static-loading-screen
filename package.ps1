$7z = "C:\Program Files\7-Zip\7z"
if (test-path static-loading-screen.op) { rm static-loading-screen.op -verbose }
& $7z a -tzip static-loading-screen.op *.as info.toml default.png LICENSE
