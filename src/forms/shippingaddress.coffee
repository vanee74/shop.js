CrowdControl = require 'crowdcontrol'
riot = require 'riot'
m = require '../mediator'
Events = require '../events'
{
  isRequired,
  isPostalRequired,
} = require './middleware'

module.exports = class AddressForm extends CrowdControl.Views.Form
  tag:  'shippingaddress'
  html: '''
    <form onsubmit={submit}>
      <yield/>
    </form>
  '''

  configs:
    'order.shippingAddress.line1':      [ isRequired ]
    'order.shippingAddress.line2':      null
    'order.shippingAddress.city':       [ isRequired ]
    'order.shippingAddress.state':      [ isRequired ]
    'order.shippingAddress.postalCode': [ isPostalRequired ]
    'order.shippingAddress.country':    [ isRequired ]

  init: ()->
    if @orderData?
      @data = @orderData

    super

    @on 'update', ()=>
      if @orderData?
        @data = @orderData

  _submit: ()->
    opts =
      id:  @data.get 'order.id'
      shippingAddress: @data.get 'order.shippingAddress'

    @errorMessage = null

    m.trigger Events.ShippingAddressUpdate
    @client.account.updateOrder(opts).then((res)=>
      m.trigger Events.ShippingAddressUpdateSuccess, res
      @update()
    ).catch (err)=>
      @errorMessage = err.message
      m.trigger Events.ShippingAddressUpdateFailed, err
      @update()

