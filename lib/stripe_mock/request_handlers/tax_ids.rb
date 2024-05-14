module StripeMock
  module RequestHandlers
    module TaxIds
      def TaxIds.included(klass)
        klass.add_handler 'get /v1/tax_ids', :list_tax_ids
        klass.add_handler 'delete /v1/tax_ids/([^/]*)', :delete_tax_id
        klass.add_handler 'post /v1/tax_ids', :create_tax_id
        klass.add_handler 'get /v1/tax_ids/([^/]*)', :get_tax_id

        klass.add_handler 'get /v1/customers/(.*)/tax_ids', :list_customer_tax_ids
        klass.add_handler 'delete /v1/customers/(.*)/tax_ids/(.*)', :delete_customer_tax_id
        klass.add_handler 'post /v1/customers/(.*)/tax_ids', :create_customer_tax_id
        klass.add_handler 'get /v1/customers/(.*)/tax_ids/(.*)', :get_customer_tax_id
      end

      def list_tax_ids(route, method_url, params, headers)
        Data.mock_list_object(tax_ids.values, params)
      end

      def delete_tax_id(route, method_url, params, headers)
        route =~ method_url
        assert_existence :tax_id, $1, tax_ids.delete($1)
      end

      def create_tax_id(route, method_url, params, headers)
        params[:id] ||= new_id('txi')
        tax_ids[ params[:id] ] = Data.mock_tax_id(params)
        tax_ids[ params[:id] ]
      end

      def get_tax_id(route, method_url, params, headers)
        route =~ method_url
        assert_existence :tax_id, $1, tax_ids[$1]
      end

      def list_customer_tax_ids(route, method_url, params, headers)
        values = tax_ids.values.select do |tax_id|
          tax_id[:owner][:type] == 'customer' && tax_id[:owner][:customer] == $1
        end

        Data.mock_list_object(values, params)
      end

      def delete_customer_tax_id(route, method_url, params, headers)
        route =~ method_url

        tax_id = tax_ids[$2]
        tax_id = nil if tax_id && (tax_id[:owner][:type] != 'customer' || tax_id[:owner][:customer] != $1)
        tax_id = tax_ids.delete($2) unless tax_id.nil?

        assert_existence :tax_id, $2, tax_id
      end

      def create_customer_tax_id(route, method_url, params, headers)
        params[:id] ||= new_id('txi')
        tax_ids[ params[:id] ] = Data.mock_tax_id(params.merge(owner: { type: 'customer', customer: $1 }))
        tax_ids[ params[:id] ]
      end

      def get_customer_tax_id(route, method_url, params, headers)
        route =~ method_url

        tax_id = tax_ids[$2]
        tax_id = nil if tax_id && (tax_id[:owner][:type] != 'customer' || tax_id[:owner][:customer] != $1)

        assert_existence :tax_id, $2, tax_id
      end
    end
  end
end

