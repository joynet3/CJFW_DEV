/**
 * @description       : 
 * @author            : 안태진
 * @group             : 
 * @last modified on  : 03-31-2022
 * @last modified by  : 안태진
**/
@isTest
public class XMLParser_test {
    static string xmlString = '<catalog><books><book><title>Advanced Apex Programming</title><subTitle>for Salesforce.com and Force.com</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
    public static testMethod void XMLParser_test() {
        XMLParser.xmlToJson(xmlString);
    }
}