import QtQuick

// What the mascot says. Kept apart so lines are easy to add or change.
QtObject {
    readonly property var random: [
        "Did you know? Reading counts as a spell if you do it long enough.",
        "Friendship report: you're doing great today ✦",
        "One more chapter. Then bed. Probably.",
        "I made a checklist for my checklists.",
        "Stars are just tiny libraries of light.",
        "Hydrate! Even unicorns need water.",
        "Spike says hi. He's busy snacking on gems.",
        "Organized your workspaces? I would have alphabetized them.",
        "That was a very decisive click.",
        "A tidy desktop is a tidy mind ✧",
        "Have you tried turning your problem into a study session?",
        "Every bug is just a puzzle that hasn't been solved yet.",
        "Remember to save your work. I learned that the hard way.",
        "Magic is mostly practice. Same as code."
    ]

    readonly property var poked: [
        "Hey! I was reading!",
        "Eep!",
        "Yes? Need a spell?",
        "Hi hi ✦",
        "Careful, my horn is sensitive."
    ]

    readonly property var landed: [
        "Whoa! Let's not do that again.",
        "I'm okay! Mostly.",
        "Was that a teleport spell? No? Okay.",
        "Wheee— ow."
    ]

    readonly property var lateNight: [
        "It's really late... even I stopped reading. Sleep soon?",
        "Princess Celestia would want you to rest.",
        "The moon is up. Time for bed ✧"
    ]

    function pick(list) {
        return list[Math.floor(Math.random() * list.length)];
    }

    function greeting(hour) {
        if (hour < 5)
            return "Still up? The stars are pretty tonight ✧";
        if (hour < 12)
            return "Good morning! Ready to learn something new?";
        if (hour < 18)
            return "Good afternoon! How's the studying going?";
        return "Good evening ✦ the night sky is my favorite.";
    }

    function chime(hour) {
        if (hour >= 0 && hour < 5)
            return pick(lateNight);
        return "It's " + hour + ":00! Time flies when you're studying.";
    }

    function music(title, artist) {
        if (artist)
            return "♪ " + artist + "? Excellent taste.";
        return "Ooh, \"" + title + "\"! Let's dance ♪";
    }
}
