var Action = function() {};

Action.prototype = {

//  Called before extension is run
run: function(parameters) {
    parameters.completionFunction( {"URL": document.URL, "title": document.title} );
},
    
//  Called after the extension is run
finalize: function(parameters) {

    //  'customJavaScript' is the dictionary we created in ActionViewController.swift
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
}
    
};

var ExtensionPreprocessingJS = new Action
