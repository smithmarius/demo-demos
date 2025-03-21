CLASS z2ui5_cl_app_demo_56 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_S_filter_pop,
        option TYPE string,
        low    TYPE string,
        high   TYPE string,
        key    TYPE string,
      END OF ty_S_filter_pop.
    DATA mt_filter TYPE STANDARD TABLE OF ty_S_filter_pop WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_S_token.

    DATA mv_value       TYPE string.
    DATA mt_token       TYPE STANDARD TABLE OF ty_S_token WITH EMPTY KEY.

    DATA mt_mapping TYPE z2ui5_if_client=>ty_t_name_value.

    TYPES:
      BEGIN OF ty_s_tab,
        selkz            TYPE abap_bool,
        product          TYPE string,
        create_date      TYPE string,
        create_by        TYPE string,
        storage_location TYPE string,
        quantity         TYPE i,
      END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    DATA mt_table TYPE ty_t_table.

    TYPES ty_t_range TYPE RANGE OF string.
    TYPES ty_s_range TYPE LINE OF ty_T_range.
    TYPES:
      BEGIN OF ty_S_filter,
        product TYPE ty_t_range,
      END OF ty_S_filter.

    DATA ms_filter TYPE ty_s_filter.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.
    METHODS z2ui5_on_render_main.
    METHODS z2ui5_on_render_pop_filter.
    METHODS z2ui5_set_data.
    METHODS map_range_to_token.

    CLASS-METHODS hlp_get_range_by_value
      IMPORTING
        VALUE(value)  TYPE string
      RETURNING
        VALUE(result) TYPE ty_S_range.

    CLASS-METHODS hlp_get_uuid
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_56 IMPLEMENTATION.


  METHOD hlp_get_range_by_value.

    DATA(lv_length) = strlen( value ) - 1.
    CASE value(1).

      WHEN `=`.
        result = VALUE #(  option = `EQ` low = value+1 ).
      WHEN `<`.
        IF value+1(1) = `=`.
          result = VALUE #(  option = `LE` low = value+2 ).
        ELSE.
          result = VALUE #(  option = `LT` low = value+1 ).
        ENDIF.
      WHEN `>`.
        IF value+1(1) = `=`.
          result = VALUE #(  option = `GE` low = value+2 ).
        ELSE.
          result = VALUE #(  option = `GT` low = value+1 ).
        ENDIF.

      WHEN `*`.
        IF value+lv_length(1) = `*`.
          SHIFT value RIGHT DELETING TRAILING `*`.
          SHIFT value LEFT DELETING LEADING `*`.
          result = VALUE #( sign = `I` option = `CP` low = value ).
        ENDIF.

      WHEN OTHERS.
        IF value CP `...`.
          SPLIT value AT `...` INTO result-low result-high.
          result-option = `BT`.
        ELSE.
          result = VALUE #( sign = `I` option = `EQ` low = value ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD hlp_get_uuid.

    DATA uuid TYPE sysuuid_c32.

    TRY.
        CALL METHOD ('CL_SYSTEM_UUID')=>create_uuid_c32_static
          RECEIVING
            uuid = uuid.
      CATCH cx_sy_dyn_call_illegal_class.

        DATA(lv_fm) = 'GUID_CREATE'.
        CALL FUNCTION lv_fm
          IMPORTING
            ev_guid_32 = uuid.
    ENDTRY.

    result = uuid.

  ENDMETHOD.


  METHOD map_range_to_token.

    CLEAR mv_value.
    CLEAR mt_token.
    LOOP AT ms_filter-product REFERENCE INTO DATA(lr_row).

      DATA(lv_value) = mt_mapping[ n = lr_row->option ]-v.
      REPLACE `{LOW}`  IN lv_value WITH lr_row->low.
      REPLACE `{HIGH}` IN lv_value WITH lr_row->high.

      INSERT VALUE #( key = lv_value text = lv_value visible = abap_true editable = abap_false ) INTO TABLE mt_token.
    ENDLOOP.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client     = client.
    app-get        = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).
    CLEAR app-get.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN `BUTTON_START`.
        z2ui5_set_data( ).

      WHEN `FILTER_UPDATE`.
        IF mv_value IS NOT INITIAL.
          DATA(ls_range) = hlp_get_range_by_value( mv_value ).
          INSERT ls_range INTO TABLE ms_filter-product.
        ENDIF.

      WHEN `FILTER_VALUE_HELP_OK`.
        CLEAR ms_filter-product.
        LOOP AT mt_filter REFERENCE INTO DATA(lr_filter).
          INSERT VALUE #(
              sign = `I`
              option = lr_filter->option
              low = lr_filter->low
              high = lr_filter->high
           ) INTO TABLE ms_filter-product.
        ENDLOOP.

      WHEN `POPUP_ADD`.
        INSERT VALUE #( key = hlp_get_uuid( ) ) INTO TABLE mt_filter.
        app-view_popup = `VALUE_HELP`.

      WHEN `POPUP_DELETE`.
        DELETE mt_filter WHERE key = app-get-t_event_arg[ 1 ].
        app-view_popup = `VALUE_HELP`.

      WHEN `POPUP_DELETE_ALL`.
        mt_filter = VALUE #( ).
        app-view_popup = `VALUE_HELP`.

      WHEN `POPUP_REFRESH`.
        app-view_popup = `VALUE_HELP`.

      WHEN `FILTER_VALUE_HELP`.
        app-view_popup = `VALUE_HELP`.

        CLEAR mt_filter.
        LOOP AT ms_filter-product REFERENCE INTO DATA(lr_product).
          INSERT VALUE #(
                   low = lr_product->low
                   high = lr_product->high
                   option = lr_product->option
                   key = hlp_get_uuid( )
           ) INTO TABLE mt_filter.

        ENDLOOP.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main = `MAIN`.

    mt_mapping = VALUE #(
    (   n = `EQ`     v = `={LOW}`    )
    (   n = `LT`     v = `<{LOW}`   )
    (   n = `LE`     v = `<={LOW}`  )
    (   n = `GT`     v = `>{LOW}`   )
    (   n = `GE`     v = `>={LOW}`  )
    (   n = `CP`     v = `*{LOW}*`  )
    (   n = `BT`     v = `{LOW}...{HIGH}` )
    (   n = `NE`     v = `!(={LOW})`    )
    (   n = `NE`     v = `!(<leer>)`    )
    (   n = `<leer>` v = `<leer>`    )
    ).

  ENDMETHOD.


  METHOD z2ui5_on_render.

    map_range_to_token( ).

    CASE app-view_popup.
      WHEN `VALUE_HELP`.
        z2ui5_on_render_pop_filter( ).
    ENDCASE.

    CASE app-view_main.
      WHEN 'MAIN'.
        z2ui5_on_render_main( ).
    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    DATA(view) = z2ui5_cl_xml_view=>factory( client ).

    view = view->page( id = `page_main`
             title          = 'abap2UI5 - List Report Features'
             navbuttonpress = client->_event( 'BACK' )
             shownavbutton  = abap_true
         )->header_content(
             )->link(
                 text = 'Demo' target = '_blank'
                 href = 'https://twitter.com/abap2UI5/status/1637163852264624139'
             )->link(
                 text = 'Source_Code' target = '_blank' href = view->hlp_get_source_code_url( )
        )->get_parent( ).

    DATA(page) = view->dynamic_page(
            headerexpanded = abap_true
            headerpinned   = abap_true
            ).

    DATA(header_title) = page->title( ns = 'f'
            )->get( )->dynamic_page_title( ).

    header_title->heading( ns = 'f' )->hbox(
        )->title( `Filter` ).
    header_title->expanded_content( 'f' ).
    header_title->snapped_content( ns = 'f' ).

    DATA(lo_box) = page->header( )->dynamic_page_header( pinnable = abap_true
         )->flex_box( alignitems = `Start` justifycontent = `SpaceBetween` )->flex_box( alignItems = `Start` ).

    lo_box->vbox(
        )->text(  `Product:`
        )->multi_input(
                    tokens          = client->_bind( mt_token )
                    showclearicon   = abap_true
                    value           = client->_bind( mv_value )
                    tokenUpdate     = client->_event( val = 'FILTER_UPDATE1'  )
                    submit          = client->_event( 'FILTER_UPDATE' )
                    id              = `FILTER`
                    valueHelpRequest  = client->_event( 'FILTER_VALUE_HELP' )
                )->item(
                        key  = `{KEY}`
                        text = `{TEXT}`
                )->tokens(
                    )->token(
                        key      = `{KEY}`
                        text     = `{TEXT}`
                        visible  = `{VISIBLE}`
                        selected = `{SELKZ}`
                        editable = `{EDITABLE}`
        ).

    lo_box->get_parent( )->hbox( justifycontent = `End` )->button(
        text = `Go` press = client->_event( `BUTTON_START` ) type = `Emphasized`
        ).

    DATA(cont) = page->content( ns = 'f' ).

    DATA(tab) = cont->table( items = client->_bind( val = mt_table ) ).

    DATA(lo_columns) = tab->columns( ).
    lo_columns->column( )->text( text = `Product` ).
    lo_columns->column( )->text( text = `Date` ).
    lo_columns->column( )->text( text = `Name` ).
    lo_columns->column( )->text( text = `Location` ).
    lo_columns->column( )->text( text = `Quantity` ).

    DATA(lo_cells) = tab->items( )->column_list_item( ).
    lo_cells->text( `{PRODUCT}` ).
    lo_cells->text( `{CREATE_DATE}` ).
    lo_cells->text( `{CREATE_BY}` ).
    lo_cells->text( `{STORAGE_LOCATION}` ).
    lo_cells->text( `{QUANTITY}` ).

    client->view_display( page->get_root( )->xml_get( ) ).

  ENDMETHOD.


  METHOD z2ui5_on_render_pop_filter.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( client ).

    lo_popup = lo_popup->dialog(
    contentheight = `50%`
    contentwidth = `50%`
        title = 'Define Conditons - Product' ).

    DATA(vbox) = lo_popup->vbox( height = `100%` justifyContent = 'SpaceBetween' ).

    DATA(pan)  = vbox->panel(
         expandable = abap_false
         expanded   = abap_true
         headertext = `Product`
     ).
    DATA(item) = pan->list(
           "   headertext = `Product`
              noData = `no conditions defined`
             items           = client->_bind_edit( mt_filter )
             selectionchange = client->_event( 'SELCHANGE' )
                )->custom_list_item( ).

    DATA(grid) = item->grid( ).

    grid->combobox(
                 selectedkey = `{OPTION}`
                 items       = client->_bind_Edit( mt_mapping )
             )->item(
                     key = '{N}'
                     text = '{N}'
             )->get_parent(
             )->input( value = `{LOW}`
             )->input( value = `{HIGH}`  visible = `{= ${OPTION} === 'BT' }`
             )->button( icon = 'sap-icon://decline' type = `Transparent` press = client->_event( val = `POPUP_DELETE` t_arg = VALUE #( ( `${KEY}` ) ) )
             ).

    lo_popup->footer( )->overflow_toolbar(
        )->button( text = `Delete All` icon = 'sap-icon://delete' type = `Transparent` press = client->_event( val = `POPUP_DELETE_ALL` )
        )->button( text = `Add Item`   icon = `sap-icon://add` press = client->_event( val = `POPUP_ADD` )
        )->toolbar_spacer(
        )->button(
            text  = 'OK'
            press = client->_event( 'FILTER_VALUE_HELP_OK' )
            type  = 'Emphasized'
       )->button(
            text  = 'Cancel'
            press = client->_event( 'FILTER_VALUE_HELP_CANCEL' )
       ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_set_data.

    "replace this with a db select here...
    mt_table = VALUE #(
        ( product = 'table'    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'chair'    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'sofa'     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'computer' create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'oven'     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = 'table2'   create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
    ).

    "put the range in the where clause of your abap sql command
    "using internal table instead
    DELETE mt_table WHERE product NOT IN ms_filter-product.

  ENDMETHOD.
ENDCLASS.
