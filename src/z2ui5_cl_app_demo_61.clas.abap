CLASS z2ui5_cl_app_demo_61 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA t_tab TYPE REF TO data.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS set_view.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_61 IMPLEMENTATION.


  METHOD set_view.

    DATA(view) = z2ui5_cl_xml_view=>factory( client ).
    DATA(page) = view->shell(
        )->page(
                title          = 'abap2UI5 - RTTI created Table'
                navbuttonpress = client->_event( 'BACK' )
                  shownavbutton = abap_true
            )->header_content(
                )->link(
                    text = 'Demo' target = '_blank'
                    href = 'https://twitter.com/abap2UI5/status/1676522756781817857'
                )->link(
                    text = 'Source_Code' target = '_blank'
                    href = view->hlp_get_source_code_url(  )
        )->get_parent( ).


    FIELD-SYMBOLS <tab> TYPE table.
    ASSIGN  t_tab->* TO <tab>.

    DATA(tab) = page->table(
            items = client->_bind_edit( <tab> )
            mode  = 'MultiSelect'
        )->header_toolbar(
            )->overflow_toolbar(
                )->title( 'Dynamic typed table'
                )->toolbar_spacer(
                )->button(
                    text  = `server <-> client`
                    press = client->_event( 'SEND' )
        )->get_parent( )->get_parent( ).

    tab->columns(
        )->column(
            )->text( 'uuid' )->get_parent(
        )->column(
            )->text( 'time' )->get_parent(
        )->column(
            )->text( 'previous' )->get_parent( ).

    tab->items( )->column_list_item( selected = '{SELKZ}'
      )->cells(
          )->input( value = '{UUID}'
          )->input( value = '{TIMESTAMPL}'
          )->input( value = '{UUID_PREV}' ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      CREATE DATA t_tab TYPE STANDARD TABLE OF ('Z2UI5_T_DRAFT').
      FIELD-SYMBOLS <tab> TYPE table.
      ASSIGN t_tab->* TO <tab>.

      INSERT VALUE z2ui5_t_draft( uuid = 'this is an uuid'  timestampl = '2023234243'  uuid_prev = 'previous' )
        INTO TABLE <tab>.

      INSERT VALUE z2ui5_t_draft( uuid = 'this is an uuid'  timestampl = '2023234243'  uuid_prev = 'previous' )
          INTO TABLE <tab>.
      INSERT VALUE z2ui5_t_draft( uuid = 'this is an uuid'  timestampl = '2023234243'  uuid_prev = 'previous' )
          INTO TABLE <tab>.

    ENDIF.

    CASE client->get( )-event.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

    set_view(  ).

  ENDMETHOD.
ENDCLASS.
