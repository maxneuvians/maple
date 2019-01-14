defmodule Maple.Constants do

  def introspection_query do
    "query IntrospectionQuery {__schema {queryType {name} mutationType {name} subscriptionType {name} types {...FullType} directives {name description locations args {...InputValue}}}} fragment FullType on __Type {kind name description fields(includeDeprecated: true) {name description args {...InputValue} type {...TypeRef} isDeprecated deprecationReason} inputFields {...InputValue} interfaces {...TypeRef} enumValues(includeDeprecated: true) {name description isDeprecated deprecationReason} possibleTypes {...TypeRef}} fragment InputValue on __InputValue {name description type {...TypeRef} defaultValue} fragment TypeRef on __Type {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name}}}}}}}}"
  end

  def types do
    ~w(
      __Directive
      __DirectiveLocation
      __EnumValue
      __Field
      __InputValue
      __Schema
      __Type
      Boolean
      Float
      ID
      Int
      String
    )
  end

end
