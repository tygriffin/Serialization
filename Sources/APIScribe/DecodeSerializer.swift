//
//  Deserializer.swift
//  APIScribe
//
//  Created by Taylor Griffin on 19/5/18.
//

import Foundation

/**
 Models implementing this protocol can use instructions in Fields
 to apply input field-by-field to the model.
 */
public protocol DecodeSerializer : Decodable, FieldMaker {
    init()
}

extension DecodeSerializer {
    
    /// Decodes data using the default state (static) state of this Serializer.
    ///
    /// - Parameters:
    ///   - data: Incoming data.
    ///   - decoder: Optional decoder. Defaults to JSONDecoder
    /// - Returns: Serializer.
    public static func decodeSerializer(
        data: Data,
        using decoder: JSONDecoder = JSONDecoder(),
        in context: Context
        ) throws -> Self {
        
        var instance = Self.init()
        instance.context = context
        return try instance.decodeSerializer(data: data, using: decoder)
    }
    
    /// Decodes data using the default state (static) state of this Serializer.
    ///
    /// - Parameters:
    ///   - data: Incoming data.
    ///   - decoder: Optional decoder. Defaults to JSONDecoder
    /// - Returns: The model that this Serializer decodes.
    public static func decode<M>(
        data: Data,
        using decoder: JSONDecoder = JSONDecoder(),
        in context: Context
        ) throws -> M where M == Model {
        
        return try Self.decodeSerializer(data: data, using: decoder, in: context).model
    }
    
    /// Decodes data with respect to the state of this Serializer.
    ///
    /// - Parameters:
    ///   - data: Incoming data.
    ///   - decoder: Optional decoder. Defaults to JSONDecoder
    /// - Returns: Serializer
    public func decodeSerializer(
        data: Data,
        using decoder: JSONDecoder = JSONDecoder()
        ) throws -> Self {
        
        guard let key = Self.deserializerInfoKey else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "APIScribe: Could not produce deserializer info key")
            )
        }
        decoder.userInfo = [key: self]
        
        return try decoder.decode(Self.self, from: data)
    }
    
    /// Decodes data with respect to the state of this Serializer.
    ///
    /// - Parameters:
    ///   - data: Incoming data.
    ///   - decoder: Optional decoder. Defaults to JSONDecoder
    /// - Returns: The model that this Serializer decodes.
    public func decode<M>(
        data: Data,
        using decoder: JSONDecoder = JSONDecoder()
        ) throws -> M where M == Self.Model {
        
        return try self.decodeSerializer(data: data, using: decoder).model
    }
    
    /// Key for pulling a deserializer out of user info.
    /// Useful for when you want non-default values in the deserializer properties
    /// used during deserialization (which happens in the model's init).
    private static var deserializerInfoKey: CodingUserInfoKey? {
        return CodingUserInfoKey(rawValue: "serialization.deserializer.primary")
    }
    
    /**
     When supporting an additional data-type, this method must be extended.
     */
    public init(from decoder: Decoder) throws {
        
        self.init()
        
        if
            let key = Self.deserializerInfoKey,
            let userInfoDeserializer = decoder.userInfo[key] as? Self {
            
            self = userInfoDeserializer
        }
        
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        var builder = FieldBuilder<Self>(modelHolder: self)
        builder.decodingContainer = container
        try makeFields(builder: &builder)
    }
}
