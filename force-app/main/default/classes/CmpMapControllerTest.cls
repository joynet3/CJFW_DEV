/**
 * @description       : 
 * @author            : (서원) won.seo@daeunextier.com
 * @group             : 
 * @last modified on  : 08-01-2022
 * @last modified by  : (서원) won.seo@daeunextier.com
**/
@isTest
private class CmpMapControllerTest {
    @isTest
    static void getPrefixTest() {

        Test.startTest();
        CmpMapController.getPrefix();
        Test.stopTest();
    }

    // @isTest
    // static void getDistanceTest() {

    //     String start = '126.8947568,37.5782834';
    //     String goal = '126.9132962,37.5630448';

    //     Test.startTest();
    //     CmpMapController.getDistance(start, goal);
    //     Test.stopTest();
    // }
}