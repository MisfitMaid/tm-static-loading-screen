namespace StaticLoadingScreen {

    UI::Texture@ currentScreen;
    UI::Font@ loadingFont;
    string currentScreenPath;
    string[] candidates;
    bool fired = false;

    void init() {
        Meta::Plugin@ bls = Meta::GetPluginFromID("BetterLoadingScreen");
        if (bls !is null && bls.Enabled) {
            UI::ShowNotification(
                Meta::ExecutingPlugin().Name,
                "BetterLoadingScreen enabled, this plugin won't do anything!"
            );
            while (bls !is null && bls.Enabled) {
                yield();
            }
        }

        @loadingFont = UI::LoadFont("droidsans.ttf", 26.f);

        imageWatcherOnce();
        startnew(imageWatcher);
        startnew(populateLoadScreen);
        startnew(previewRotator);
    }

    void step() {

    }

    void imageWatcher() {
        while (true) {;
            sleep(30000);
            imageWatcherOnce();
        }
    }
    void imageWatcherOnce() {
        candidates = getImageList();
    }

    void previewRotator() {
        while (true) {
            sleep(5000);
            if (bgPreview) populateLoadScreen();
        }
    }

    void populateLoadScreen() {
        if (candidates.Length == 0) {
            IO::FileSource iofs("default.png");
            @currentScreen = UI::LoadTexture(iofs.Read(iofs.Size()));
            currentScreenPath = "";
            trace("[SLS] loading placeholder image");
        } else {
            uint pick = Math::Rand(0, candidates.Length);
            while (bgNoDupes && candidates.Length > 1 && candidates[pick] == currentScreenPath) {
                pick = Math::Rand(0, candidates.Length);
            }
            if (candidates[pick] == currentScreenPath) {
                trace("[SLS] Keeping existing image loaded: " + candidates[pick]);    
                return;
            }
            IO::File iof(candidates[pick], IO::FileMode::Read);
            @currentScreen = UI::LoadTexture(iof.Read(iof.Size()));
            currentScreenPath = candidates[pick];
            iof.Close();
            trace("[SLS] loading image: " + candidates[pick]);
        }
    }

    void render() {
        if (currentScreen is null) return;

        if (!bgPreview) {
            NGameLoadProgress_SMgr@ loadProgress = GetApp().LoadProgress;
            if (loadProgress is null || loadProgress.State == NGameLoadProgress_SMgr::EState::Disabled) {
                if (fired) {
                    startnew(populateLoadScreen);
                }
                fired = false;
                return;
            }
        }

        UI::DrawList@ dl = UI::GetBackgroundDrawList();
        vec2 screen(Draw::GetWidth(), Draw::GetHeight());
        vec2 img = getImageSize(screen, currentScreen.GetSize(), bgFormat);
        dl.AddRectFilled(vec4(vec2(0), screen), bgColor);

        if (bgFormat == BackgroundFormat::Stretch) {
            dl.AddImage(currentScreen, vec2(0), screen);
        } else {
            dl.AddImage(currentScreen, screen/2.f - img/2.f, img);
        }

        string loadText = "Loading";
        uint numDots = ((Time::Now % 800) / 200);
        for (uint i = 0; i < numDots; i++) {
            loadText += ".";
        }

        dl.AddText(screen * loadTextOffset, textColor, loadText, loadingFont);

        fired = true;
    }

    string[] getImageList() {
        if (!IO::FolderExists(imageFolder)) IO::CreateFolder(imageFolder);
        
        string[] files = IO::IndexFolder(imageFolder, true);
        string[] filtered;
        string[] supportedFormats = getSupportedFormats();

        for (uint i = 0; i < files.Length; i++) {
            if (i % 500 == 0) yield(); // smooth out lag spike for excessively large image pools
            bool supported = false;
            for (uint ii = 0; ii < supportedFormats.Length; ii++) {
                if (files[i].ToLower().EndsWith(supportedFormats[ii])) supported = true;
            }
            if (supported) {
                filtered.InsertLast(files[i]);
            }
        }
        return filtered;
    }

    string[] getSupportedFormats() {
        string[] x;
        x.InsertLast(".jpg");
        x.InsertLast(".jpeg");
        x.InsertLast(".png");
        x.InsertLast(".tga");
        x.InsertLast(".bmp");
        x.InsertLast(".psd");
        x.InsertLast(".gif");
        x.InsertLast(".hdr");
        x.InsertLast(".pic");
        return x;
    }

    vec2 getImageSize(vec2 screen, vec2 img, BackgroundFormat bf) {
        float r_width = screen.x / img.x;
        float r_height = screen.y / img.y;

        switch (bf) {
            case BackgroundFormat::Cover:
                return img * Math::Max(r_width, r_height);
            case BackgroundFormat::Contain:
                return img * Math::Min(r_width, r_height);
            case BackgroundFormat::Center:
            case BackgroundFormat::Stretch:
            default:
                return img;
        }
        
    }
}
