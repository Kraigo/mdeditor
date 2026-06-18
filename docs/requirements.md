Use Flutter provider for state manager.

## Design
It should use flutter material design
It should be Desktop app.

## Usage flow
When you open app it should show empty document. On the top is shown Tabs list vscode with first Noname document. When I hover over document tabs close app appears. When closed all tabs - applications should close.

Above the tabs should be button groups with formatting text (Bold, Italic, Striked, Underlined, List, Checkbox, Link). On the right side should be toggle button to show evaluated document or raw document.

When I highlight text and click Formatting button it should apply md styles, overwise it should enabled this mode for next input. Current mode should be reflected as active button of related format.

On the left side of this toppest navbar should be icon to open a file. It should call native file picker and select MD file, it should be opened in new file. 