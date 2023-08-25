/**
 * @description       : 공통으로 쓰는 메소드 모음 , 각 클래스에서 호출해서 사용 
 * @author            : eunyoung.choi@dkbmc.com
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : eunyoung.choi@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   08-01-2023   eunyoung.choi@dkbmc.com   Initial Version
**/

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import { CloseActionScreenEvent } from 'lightning/actions';


/**
* Quick Action Close
*
*/
const utilCloseActionScreenEvent = () => {
    dispatchEvent(new CloseActionScreenEvent());
};

/**
*  Lighting Alert
*
*@param  label option 헤더내용
*@param  message option 메세지
*@param  variant option (header , headerless)
*@param  theme option 테마 
                        default: white
                        shade: gray
                        inverse: dark blue
                        alt-inverse: darker blue
                        success: green
                        info: gray-ish blue
                        warning: yellow
                        error: red
                        offline: ​black​
                        
*/
const utilAlert = async(label, message, variant, theme) => {
    await LightningAlert.open({
        message: message,
        theme: theme, // a red theme intended for error states
        label: label, // this is the header text
        variant: variant 
        //? variant : 'headerless',
    });
}

/**
* ShowToast 
*
*@param  title option 헤더내용
*@param  message option 메세지
*@param  variant option (info:default, success, warning, error)
*/
const utilShowToast = (title, message, variant) => {
    const event = new ShowToastEvent({
        title: title,
        message:message,
        variant:variant,
    });

    dispatchEvent(event);
}


/**
* Confrim 
*
*@param  label option 헤더내용
*@param  message option 메세지
*@param  variant option (header , headerless)
*@param  theme  option  테마 
                        default: white
                        shade: gray
                        inverse: dark blue
                        alt-inverse: darker blue
                        success: green
                        info: gray-ish blue
                        warning: yellow
                        error: red
                        offline: ​black​

*/
const utilConfrim = async (label, message, variant, theme) => {
    
    const result = await LightningConfirm.open({
            message: message,
            variant: variant,
            //? variant : 'headerless',
            label: label,
            theme : theme ? theme : 'default'
            // setting theme would have no effect
    });
    return result;
}


/**
custom Style 세팅 
*@author eunyoung.choi
*@param  style  : 각각의 component JS에 세팅해놓은 custom style
*@param  id  : 각각의 component JS에 세팅해놓은 custom style 의 id
*@since 2023-08-01  내용 작성
*/
const setCustomStyle = (style, id) => {
    let styleElement = document.createElement("style");
    styleElement.setAttribute("id", id);
    styleElement.innerHTML = style;
    document.body.appendChild(styleElement);
}

/**
custom Style 세팅 삭제
*@author eunyoung.choi
*@param  id  : 각각의 component JS에 세팅해놓은 custom style 의 id
*@since 2023-08-01  내용 작성
*/
const removeCustomStyle = (id) => {
    const target = document.querySelector("style#" + id);
    if(target) target.remove();
}

export {
    utilCloseActionScreenEvent,
    utilAlert,
    utilShowToast,
    utilConfrim,
    setCustomStyle,
    removeCustomStyle
};