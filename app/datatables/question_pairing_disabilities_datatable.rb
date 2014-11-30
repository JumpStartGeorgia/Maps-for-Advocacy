class QuestionPairingDisabilitiesDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :number_with_delimiter, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: QuestionPairingDisability.with_names_count,
      iTotalDisplayRecords: items.total_entries,
      aaData: data
    }
  end

private

  def data
    items.map do |item|
      [
        item.certified_text,
        item.question_category,
        item.question_subcategory,
        item.question,
        item.disability_name,
        view_link(item),
        action_links(item)
      ]
    end
  end

  def items
    @items ||= fetch_items
  end

  def view_link(item)
    x = ''
    if item.has_content?
      x << link_to(I18n.t('helpers.links.view'), 
                help_text_path(question_pairing_id: item.question_pairing_id, :disability_ids => [item.disability_id], :locale => I18n.locale), 
                :class => 'btn help-text-fancybox')
    end
    return x.html_safe
  end

  def action_links(item)
    x = ''
    x << link_to(I18n.t("helpers.links.edit"),
                      edit_admin_question_pairing_disability_path(item, :locale => I18n.locale), 
                      :class => 'btn btn-mini')
    return x.html_safe
  end

  def fetch_items
    QuestionPairingDisability.with_names(search: params[:sSearch], 
      sort_col: sort_column, sort_dir: sort_direction,
      offset: page, limit: per_page)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[is_certified question_category_parent question_category_child question disability_name has_content]
    columns[params[:iSortCol_0].to_i]
  end

  def create_columns
    cols = []

    return cols
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
