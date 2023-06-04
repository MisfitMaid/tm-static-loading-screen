namespace StaticLoadingScreen {
    [Setting name="Preview" category="Settings" description="Renders the current loading screen and cycles through available images."]
    bool bgPreview = false;

    [Setting name="Background format" category="Settings" description="How images should be rescaled. Enable 'Preview' to see what each option does."]
    BackgroundFormat bgFormat = BackgroundFormat::Center;

    [Setting name="Background color" color category="Settings" description="The color to show behind the image. Useless under Contain or Stretch modes"]
    vec4 bgColor = UI::GetStyleColor(UI::Col::TitleBg);

    [Setting name="Text color" color category="Settings" description="The color of the 'Loading...' text, if enabled"]
    vec4 textColor = UI::GetStyleColor(UI::Col::Text);

    [Setting name="Loading text" category="Settings" description="Show a 'Loading...' text option"]
    bool showLoadText = true;

    [Setting name="Prevent duplicate picks" category="Settings" description="Prevent the same image being used twice in a row."]
    bool bgNoDupes = true;

    [Setting name="Loading text offset" category="Settings" description="Where to put the 'Loading...' text"]
    vec2 loadTextOffset = vec2(0.025, 0.950);

    [Setting name="Image folder" category="Settings" description="Where to search for images"]
    string imageFolder = IO::FromStorageFolder("screens");

    enum BackgroundFormat {
        Center,
        Cover,
        Contain,
        Stretch,
    }

    [SettingsTab name="Add Pictures" order="1" icon="FileO"]
    void settingsUwU() { // uwu
        UI::TextWrapped("To add images, place them in the folder " + imageFolder);

        if (UI::Button(Icons::FolderOpenO + " Open image folder")) {
            OpenExplorerPath(imageFolder);
        }
        UI::SameLine();
        if (UI::Button(Icons::Search + " Scan for new images")) {
            startnew(imageWatcherOnce);
        }
        UI::SameLine();
        if (UI::Button(Icons::Download + " Download BetterLoadingScreen images")) {
            startnew(importBLS);
        }

        UI::TextWrapped("The following file formats are supported by Openplanet: " + string::Join(getSupportedFormats(), ", "));

        string folder = imageFolder;
        if (UI::BeginTable("Images", 2, UI::TableFlags::SizingFixedFit)) {
            	UI::TableSetupColumn("Filename", UI::TableColumnFlags::WidthStretch);
				UI::TableSetupColumn("Delete", UI::TableColumnFlags::NoResize);
				UI::TableSetupScrollFreeze(0,1);
				UI::TableHeadersRow();
			for (uint i = 0; i < candidates.Length; i++) {
                UI::TableNextRow();
				UI::TableNextColumn();
                if (candidates[i] == currentScreenPath) {
                    UI::Text(Icons::Star);
                    UI::SameLine();
                }
                UI::Text(candidates[i].Replace(folder, ""));

                UI::PushID(i + "_rm");
				UI::TableNextColumn();
				if (UI::Button(Icons::TrashO)) {
					IO::Delete(candidates[i]);
                    startnew(imageWatcherOnce);
				}
				UI::PopID();
			}
			UI::EndTable();
		}
    }
}
