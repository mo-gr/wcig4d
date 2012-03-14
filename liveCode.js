function refreshLiveCoding(e, basename) {
    var src = document.getElementById( basename + '_src');
    src = src || document.getElementById( basename );
    var html = src.innerText;
    var script = html.replace("<script type=\"text/javascript\">", "").replace("</script>", "");
    console.log('script:\n' + script);
    if ( script ) {
        var scriptTag = document.createElement('script');
        scriptTag.type = 'text/javascript';
        scriptTag.innerText = script;
        document.body.appendChild(scriptTag);
    }
    if ( e ) {
        e.preventDefault();
        e.stopPropagation();
    }
    return false;
}

function refreshLiveCoffee(e, basename) {
    var src = document.getElementById( basename + '_src');
    var dst = document.getElementById( basename + '_embed');
    var html = src.innerText;
    var script = html.replace("<script type=\"text/coffeescript\">", "").replace("</script>", "");
    console.log(script);
    dst.innerHTML = '// Generated Javascript:\n' + CoffeeScript.compile(script, {bare:true});
    prettyPrint();
    if ( e ) {
        e.preventDefault();
        e.stopPropagation();
    }
    return false;
}

function executeLiveCoffee(e, basename) {
    var src = document.getElementById(basename + '_src');
    var html = src.innerText;
    var script = html.replace("<script type=\"text/coffeescript\">", "").replace("</script>", "");
    if ( script ) {
        html = html.replace(/<script type=\"text\/coffeescript\">([^<]*)<\/script>/, '');
        var scriptTag = document.createElement('script');
        scriptTag.type = 'text/javascript';
        scriptTag.innerText = CoffeeScript.compile(script, {bare:true});
        console.log('script: ' + scriptTag.innerText);
        document.body.appendChild(scriptTag);
    }
    if ( e ) {
        e.preventDefault();
        e.stopPropagation();
    }
    return false;
}

// Sync a contenteditable containing html with a div containing the result.
function manageLiveCoding(basename) {
    var src = document.getElementById( basename + '_src');
    src = src || document.getElementById( basename );
    src.addEventListener('blur', function (e) {
        window.setTimeout(function () {
            prettyPrint();
        }, 0);
    }, false);
}