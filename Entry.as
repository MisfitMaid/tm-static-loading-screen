void Main() {
    StaticLoadingScreen::init();
    while(true) {
        StaticLoadingScreen::step();
        yield();
    }
}

void Render() {
    StaticLoadingScreen::render();
}
