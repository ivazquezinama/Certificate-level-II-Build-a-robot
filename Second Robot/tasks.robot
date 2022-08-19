*** Settings ***
Documentation       Order Robots from RobotSpareBin Industries Inc.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Desktop
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.Archive
Library             RPA.Robocorp.Vault
Library             RPA.Dialogs


*** Tasks ***
Order Robots from RobotSpareBin Industries Inc
    Download the orders file
    Open the Order Robots WebSite
    Get order file and make the orders
    Make ZIP file of the orders receipts
    Read the vault secret and log the findings
    Confirmation dialog


*** Keywords ***
Download the orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Open the Order Robots WebSite
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    Yep

Complete an order form
    [Arguments]    ${order_file}
    Select From List By Value    head    ${order_file}[Head]
    Select Radio Button    body    ${order_file}[Body]
    Input Text    class:form-control    ${order_file}[Legs]
    Input Text    address    ${order_file}[Address]

Get order file and make the orders
    ${order_files}=    Read table from CSV    orders.csv

    FOR    ${order_file}    IN    @{order_files}
        Complete an order form    ${order_file}

        Preview the order

        Order the robot

        Get rid of the error

        Save the receipt    ${order_file}

        Save image of the robot ordered    ${order_file}

        Merge receipt with image of the robot order    ${order_file}

        Remove unnecessary files    ${order_file}

        Make a folder with all the receipts    ${order_file}

        Move to another order
    END

Preview the order
    Wait Until Element Is Visible    preview
    Click Button    preview

Order the robot
    Wait Until Element Is Visible    id:order
    Click Button    order

Get rid of the error
    ${receipt_alert}=    Is Element Visible    receipt
    WHILE    ${receipt_alert} == ${False}
        Wait Until Element Is Visible    id:order
        Click Button    order
        ${receipt_alert}=    Is Element Visible    receipt
    END

Save the receipt
    [Arguments]    ${order_file}
    Wait Until Element Is Visible    receipt
    ${order_robot_receipt}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${order_robot_receipt}    ${OUTPUT_DIR}${/}${order_file}[Order number].pdf

Save image of the robot ordered
    [Arguments]    ${order_file}
    Wait Until Page Contains Element    id:robot-preview-image
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}${order_file}[Order number].png

Merge receipt with image of the robot order
    [Arguments]    ${order_file}
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}${order_file}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}${order_file}[Order number].png
    Add Files To Pdf    ${files}    Receipt-Order-Nro.${order_file}[Order number].pdf

Remove unnecessary files
    [Arguments]    ${order_file}
    Remove File    ${order_file}[Order number].png
    Remove File    ${order_file}[Order number].pdf

Make a folder with all the receipts
    [Arguments]    ${order_file}
    Create Directory    Receipts
    Move File
    ...    Receipt-Order-Nro.${order_file}[Order number].pdf
    ...    Receipts/Receipt-Order-Nro.${order_file}[Order number].pdf    overwrite=true

Move to another order
    Wait Until Page Contains Element    order-another
    Click Button    order-another
    Click Button    Yep

Make ZIP file of the orders receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    OrdersReceipts.zip

Read the vault secret and log the findings
    ${secret}=    Get Secret    RobotScrets
    Log    ${secret}[username]
    Log    ${secret}[password]

Confirmation dialog
    Add heading    Do you want to close de WebSite?
    Add submit buttons    buttons=No,Yes    default=Yes
    ${result}=    Run dialog
    IF    $result.submit == "Yes"    Close Browser
