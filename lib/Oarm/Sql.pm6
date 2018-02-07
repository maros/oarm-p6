class Oarm::Sql {

    # todo cte

    # insert
    # INSERT INTO table_name [ AS alias ] [ ( column_name [, ...] ) ]
    #     { DEFAULT VALUES | VALUES ( { expression | DEFAULT } [, ...] ) [, ...] | query }
    #     [ ON CONFLICT [ conflict_target ] conflict_action ]
    #     [ RETURNING * | output_expression [ [ AS ] output_name ] [, ...] ]

    # update
    # UPDATE [ ONLY ] table_name [ * ] [ [ AS ] alias ]
    # SET { column_name = { expression | DEFAULT } |
    #       ( column_name [, ...] ) = ( { expression | DEFAULT } [, ...] ) |
    #       ( column_name [, ...] ) = ( sub-SELECT )
    #     } [, ...]
    # [ FROM from_list ]
    # [ WHERE condition | WHERE CURRENT OF cursor_name ]
    # [ RETURNING * | output_expression [ [ AS ] output_name ] [, ...] ]

    # delete
    # DELETE FROM [ ONLY ] table_name [ * ] [ [ AS ] alias ]
    # [ USING using_list ]
    # [ WHERE condition | WHERE CURRENT OF cursor_name ]
    # [ RETURNING * | output_expression [ [ AS ] output_name ] [, ...] ]
}
