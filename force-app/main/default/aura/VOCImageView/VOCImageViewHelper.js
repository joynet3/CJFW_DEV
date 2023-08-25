({
	// Toast 메시지
	showToast : function(type, message) {
		let evt = $A.get("e.force:showToast");
		evt.setParams({
			key     : "info_alt",
			type    : type,
			message : message
		});
		evt.fire();
	},
	// 로딩바 활성화
	showSpinner: function (component) {
		/* this will show the <lightning:spinner /> */
		component.set('v.isShowSpinner', true);
	},
	// 로딩바 비활성화
	hideSpinner: function (component) {
		/* this will hide the <lightning:spinner /> */
		component.set('v.isShowSpinner', false);
	},
})