CLASS z2ui5_cl_app_demo_10 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_10 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    CASE client->get( )-event.
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).
    ENDCASE.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( client )->shell(
        )->page(
            title           = 'abap2UI5 - Demo Layout'
            navbuttonpress  = client->_event( 'BACK' )
            shownavbutton   = abap_true
             ).

    page->header_content(
      )->button( text = 'button'
      )->text( 'text'
      )->link(
        text = 'link' target = '_blank'
        href = 'https://twitter.com/abap2UI5'
      )->link(
        text = 'Source_Code' target = '_blank'
        href = page->hlp_get_source_code_url( )
       ).

    page->sub_header(
        )->overflow_toolbar(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/abap2UI5'
            )->toolbar_spacer(
            )->text( 'subheader'
            )->toolbar_spacer(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/abap2UI5' ).

    DATA(grid) = page->grid( 'L4 M4 S4' )->content( 'layout' ).

    grid->simple_form( 'Grid width 33%' )->content( 'form'
       )->button( text = 'button'
       )->text( 'text'
       )->link( text = 'link' href = 'https://twitter.com/abap2UI5' ).

    grid->simple_form( 'Grid width 33%' )->content( 'form'
      )->button( text = 'button'
      )->text( 'text'
      )->link( text = 'link' href = 'https://twitter.com/abap2UI5' ).

    grid->simple_form( 'Grid width 33%' )->content( 'form'
      )->button( text = 'button'
      )->text( 'text'
      )->link( text = 'link' href = 'https://twitter.com/abap2UI5' ).

    grid = page->grid( 'L12 M12 S12' )->content( 'layout' ).

    grid->simple_form( 'grid width 100%' )->content( 'form'
      )->button( text = 'button'
      )->text( 'text'
      )->link( text = 'link' href = 'https://twitter.com/abap2UI5' ).

    page->footer(
        )->overflow_toolbar(
            )->button( text = 'button'
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/abap2UI5'
            )->toolbar_spacer(
            )->text( 'footer'
            )->toolbar_spacer(
            )->text( 'text'
            )->link( text = 'link' href = 'https://twitter.com/abap2UI5'
            )->button( text = 'reject' type = 'Reject'
            )->button( text = 'accept' type = 'Success' ).

    client->view_display( page->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
