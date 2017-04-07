"@fixture login";
"@page https://www.google.com";
"@auth test@test.com:test@test";

"@test"["login"] = {
    '1.Hover over link "Log In"': function() {
        act.hover(":containsExcludeChildren(Log In)");
    },
    '2.Click link "Log In"': function() {
        act.click(":containsExcludeChildren(Log In)");
    },
    "3.Assert": function() {
        eq($(".CTA.CTA--Green").eq(2).length > 0, true, "Login Button");
    }
};

