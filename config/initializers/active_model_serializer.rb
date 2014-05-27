module ActiveModel
  class Serializer
    module Associations
      class HasMany

        def key_with_polymorphism
          return @name if !option(:key) && option(:polymorphic)
          key_without_polymorphism
        end
        alias_method_chain :key, :polymorphism

        def serialize_ids_with_polymorphism
          if option(:polymorphic)
            SerializeIdsWithPolymorphism.call(associated_object)
          else
            serialize_ids_without_polymorphism
          end
        end
        alias_method_chain :serialize_ids, :polymorphism

      end
    end
  end
end
