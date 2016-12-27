({
    render : function(component, helper){
        var ret = this.superRender();
        
        helper.renderIcon(component);
        return ret;
    }
})