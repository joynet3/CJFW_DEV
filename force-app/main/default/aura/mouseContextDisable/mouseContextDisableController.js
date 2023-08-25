({
	doInit : function(component, event, helper) {
        document.addEventListener('contextmenu', event => event.preventDefault());		
	}
})