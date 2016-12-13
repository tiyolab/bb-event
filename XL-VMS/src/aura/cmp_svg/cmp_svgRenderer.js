({
    render : function(component, helper){
        var classname = component.get("v.class");
        var xlinkhref = component.get("v.xlinkHref");
        var ariaHidden = component.get("v.ariaHidden");
        
        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute('class', classname);
        svg.setAttribute('aria-hidden', ariaHidden);
        svg.innerHTML = '<use xlink:href="' + xlinkhref + '"></use>';
        return svg;
    }
})