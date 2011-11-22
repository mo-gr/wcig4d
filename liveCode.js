function refreshLiveCoding(e, basename) {
    var src = $('#' + basename + '_src')[0];
    var dst = $('#' + basename + '_embed')[0];
    var html = src.innerText;
    var scripts = /<script type=\"text\/javascript\">([^<]*)<\/script>/i.exec(html);
    console.log('scripts: ' + scripts);
    if ( scripts ) {
        var scriptCode = scripts[1];
        html = html.replace(/<script>[^<]*<\/script>/, '');
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.innerText = scriptCode;
        document.body.appendChild(script);
    }
    dst.innerHTML = html;
    if ( e ) {
        e.preventDefault();
        e.stopPropagation();
    }
    try {
        initstars();
    } catch (e) {
    }
    return false;
}

function refreshLiveCoffee(e, basename) {
    var src = $('#' + basename + '_src')[0];
    var dst = $('#' + basename + '_embed')[0];
    var html = src.innerText;
    var scripts = /<script type=\"text\/coffeescript\">([^<]*)<\/script>/i.exec(html);
    dst.innerHTML = '// Generated Javascript:\n' +  CoffeeScript.compile(scripts[1], {bare : true});
    prettyPrint();
    if ( e ) {
        e.preventDefault();
        e.stopPropagation();
    }
    try {
        initstars();
    } catch (e) {
    }
    return false;
}

// Sync a contenteditable containing html with a div containing the result.
function manageLiveCoding(basename) {
    var src = $('#' + basename + '_src')[0];
    src.addEventListener('keydown', function (e) {
        if ( e.keyCode == 9 )  // tab
            return true;
        window.setTimeout(function () {
        }, 0);
        e.stopPropagation();
        return false;
    }, false);
    src.addEventListener('blur', function (e) {
        window.setTimeout(function () {
            prettyPrint();
        }, 0);
    }, false);
}