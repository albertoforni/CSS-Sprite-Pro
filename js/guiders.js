guiders.createGuider({
    buttons: [{name: "Next"}, {name: "Close"}],
    description: "Let us introduce how the application works",
    id: "guider1",
    next: "guider2",
    title: ""
});

guiders.createGuider({
    attachTo: "#prevArea",
    highlight: "#prevArea",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "First you need to drag and drop your icons to this area",
    id: "guider2",
    next: "guider3",
    position: 3,
    title: "Drag & Drop"
});

guiders.createGuider({
    attachTo: "#codeStyle .selected",
    highlight: "#codeStyle .selected",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "Select your code style form the drop down list",
    id: "guider3",
    next: "guider4",
    position: 9,
    title: "Chose your code style"
});

guiders.createGuider({
    attachTo: "#prevArea",
    highlight: ".canvasBackground",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "Continue add icons to this area if you want",
    id: "guider4",
    next: "guider5",
    position: 3,
    title: "Drag & Drop"
});

guiders.createGuider({
    attachTo: "#fit",
    highlight: "#fit",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "When you're done fit the canvas to the icons",
    id: "guider5",
    next: "guider6",
    position: 6,
    title: "Fit"
});

guiders.createGuider({
    attachTo: "#convert",
    highlight: "#convert",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "Then, if need it, convert your file name \"iconName_psudoClass.png\" to psudo-classes",
    id: "guider6",
    next: "guider7",
    position: 6,
    title: "Convert"
});

guiders.createGuider({
    attachTo: "#clear",
    highlight: "#clear",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "If you get wrong you can always clear your canvas and restart",
    id: "guider7",
    next: "guider8",
    position: 6,
    title: "Ops! Clear"
});

guiders.createGuider({
    attachTo: "#downloadLink",
    highlight: "#downloadLink",
    buttons: [{name: "Next"}, {name: "Back"}, {name: "Close"}],
    description: "You're ready to download your css sprite",
    id: "guider8",
    next: "guider9",
    position: 9,
    title: "Download"
});

guiders.createGuider({
    attachTo: "#copyAll",
    highlight: "#copyAll",
    buttons: [{name: "Back"}, {name: "Close"}],
    description: "copy you're code to the clipboard and past in your css file",
    id: "guider9",
    next: "guider10",
    position: 9,
    title: "Copy the code"
});
