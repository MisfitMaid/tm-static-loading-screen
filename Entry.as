void Main() {
    StaticLoadingScreen::init();
    while(true) {
        StaticLoadingScreen::step();
        yield();
    }
}

void RenderEarly() {
    StaticLoadingScreen::render();
}
