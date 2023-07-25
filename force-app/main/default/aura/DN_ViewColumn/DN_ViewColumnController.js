({
    // Component Init
    fnInit : function(component, event, helper) {
        var header = component.get("v.header");
        var data = component.get("v.data");

        var typeOfHeader = typeof header;
        if(typeOfHeader === "object") {
            component.set("v.columnValue", data[header.fieldName]);
            component.set("v.headerType", header.type);
        } else {
            component.set("v.columnValue", data[header]);
            component.set("v.headerType", "STRING");
        }
    },
})