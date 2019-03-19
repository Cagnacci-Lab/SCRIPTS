## [Data type](DATA_TYPE.md)

In this document we present the *main* GDAL data types:

| Data type        | Description                               | Range                                        |
|:-----------------|:------------------------------------------|:---------------------------------------------|
| UnknownDataType  | Unknown or unspecified type               |                                              |
| Byte             | Eight bit unsigned integer (quint8)       | Byte (-128 to 127)                           |
| UInt16           | Sixteen bit unsigned integer (quint16)    | 2 Bytes, Unsigned integer (0 to 65535)       |
| Int16            | Sixteen bit signed integer (qint16)       | 2 Bytes, Integer (-32768 to 32767)           |
| UInt32           | Thirty two bit unsigned integer (quint32) | 4 Bytes, Unsigned integer (0 to 4294967295)  |
| Int32            | Thirty two bit signed integer (qint32)    | 4 Bytes, Integer (-2147483648 to 2147483647) |
| Float32          | Thirty two bit floating point (float)     | 32 Bytes (-3.4e+38 to +3.4e+38)              |
| Float64          | Sixty four bit floating point (double)    | 64 Bytes (-1.7e+308 to +1.7e+308)            |

For reasons of space and computational power, it is suggested to choose the right type based on your analysis and data (in case of continuous variables, **integer** types will not carry decimlas, therefore information is lost).
