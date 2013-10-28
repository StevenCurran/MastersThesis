function [allDigitsStruct] = loadAllDigitsIntoStruct(fullImageList, imageLabels)
    field0 = 'f0';  value0 = loadDigit(0,fullImageList,imageLabels);
    field1 = 'f1';  value1 = loadDigit(1,fullImageList,imageLabels);
    field2 = 'f2';  value2 = loadDigit(2,fullImageList,imageLabels);
    field3 = 'f3';  value3 = loadDigit(3,fullImageList,imageLabels);
    field4 = 'f4';  value4 = loadDigit(4,fullImageList,imageLabels);
    field5 = 'f5';  value5 = loadDigit(5,fullImageList,imageLabels);
    field6 = 'f6';  value6 = loadDigit(6,fullImageList,imageLabels);
    field7 = 'f7';  value7 = loadDigit(7,fullImageList,imageLabels);
    field8 = 'f8';  value8 = loadDigit(8,fullImageList,imageLabels);
    field9 = 'f9';  value9 = loadDigit(9,fullImageList,imageLabels);
    allDigitsStruct = struct(field0,value0,field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field7,value7,field8,value8,field9,value9);

end

