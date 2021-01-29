# Development
> Ruby : A dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.

> Rails : Optimizing for programmer happiness with Convention over Configuration is how we roll.

## Pull local database for an  app review
```bash
heroku pg:push #{app_name}_development DATABASE_URL --app #{app_name}-pr-#{pr_id}
```

## Coding Style

- ruby : https://github.com/bbatsov/ruby-style-guide
- rspec : https://github.com/reachlocal/rspec-style-guide, http://www.betterspecs.org/
- rails : http://rails-bestpractices.com/
- rubocop avant de *commiter* (au pire avant de *push*)
- Arrangez le code par ordre alphabétique si possible. (cela facilite aussi les merges)
- Le code doit être facilement lisible, pas d'abréviation si possible
- La limite est de 120 char. par ligne
- Svp, lisez les best practices, au minimum ruby et rspec

---

### Affichage des monnaies
```ruby
number_to_currency(price)
=> 31,16 €
```

### Affichage des dates
```ruby
[1] pry(main)> I18n.localize(DateTime.current, format: :short)
=> "13 nov. 23h26"
[2] pry(main)> I18n.localize(DateTime.current.to_date, format: :short)
=> "13 nov."
[3] pry(main)> I18n.localize(DateTime.current)
=> "13 novembre 2017 23h 27min 05s"
[4] pry(main)> I18n.localize(DateTime.current.to_date)
=> "13/11/2017"
```
```yml
# config/locales/fr.yml
formats:
  default: "%d/%m/%Y"
  short: "%e %b"
  long: "%e %B %Y"
```

---

```bash
bundle exec annotate -p bottom -ki-e tests,fixtures,factories,serializers -f markdown --classified-sort
```

---

# Ajax BootstrapTable listing
Model : ResourceName

```ruby
# routes.rb
resource :resource_name, concerns: :bootstrap_tableable
```

```ruby
# app/views/#{resource_name}s/index.json.jbuilder
json.total @resource_names_count
json.rows(@resource_names) do |resource_name|
  json.id link_to("##{booking.id}", resource_name_path(resource_name))
  json.excluding_taxes_price "<span class='text-nowrap'>#{number_to_currency(resource_name.excluding_taxes_price)}</span>"
end
```

```ruby
# app/controllers/#{resource_name}s_controller.rb
def table_columns
  json = [
    { field: 'id', sortable: true, title: ResourceName.model_name.human },
    { field: 'excluding_taxes_price', sortable: true, align: 'right', title: ResourceName.human_attribute_name(:amount) },
  ]
  render json: json.to_json
end

def index
  @resource_names = ResourceName.all
  @resource_names_count = @resource_names.count
  @resource_names = filter(@resource_names, params)
end
```

```haml
%table.table.table-no-bordered#resource_names_table
:coffeescript
  $.ajax(url: "#{table_columns_resource_names_path}").done (json) ->
    $('#resource_names_table').bootstrapTable
      columns: json,
      url: "#{resource_names_path}"
```
