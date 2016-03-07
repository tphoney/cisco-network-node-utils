# Copyright (c) 2016 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'ciscotest'
require_relative '../lib/cisco_node_utils/itd_service'

include Cisco
# TestInterface - Minitest for general functionality
# of the ItdService class.
class TestItdService < CiscoTestCase
  # Tests

  def setup
    super
    config 'no feature itd' if n79k_platform?
  end

  def teardown
    config 'no feature itd' if n79k_platform?
    super
  end

  def n79k_platform?
    /N(7|9)/ =~ node.product_id
  end

  def test_itd_device_group_create_destroy
    if node.product_id =~ /N(3|5|6)/ || platform == :ios_xr
      itd = ItdService.new('dummy', false)
      assert_nil(itd.device_group)
      assert_raises(Cisco::UnsupportedError) do
        itd.device_group = 'new_dummy'
      end
      return
    end
    i1 = ItdService.new('abc')
    i2 = ItdService.new('BCD')
    i3 = ItdService.new('xyzABC')
    assert_equal(3, ItdService.itds.keys.count)

    i2.destroy
    assert_equal(2, ItdService.itds.keys.count)

    i1.destroy
    i3.destroy
    assert_equal(0, ItdService.itds.keys.count)
  end

  def test_access_list
    itd = ItdService.new('new_group')
    config 'ip access-list include'
    config 'ip access-list exclude'
    itd.access_list = 'include'
    itd.exclude_access_list = 'exclude'
    assert_equal('include', itd.access_list)
    assert_equal('exclude', itd.exclude_access_list)
    itd.access_list = itd.default_access_list
    itd.exclude_access_list = itd.default_exclude_access_list
    assert_equal(itd.default_access_list,
                 itd.access_list)
    assert_equal(itd.default_exclude_access_list,
                 itd.exclude_access_list)
    config 'no ip access-list include'
    config 'no ip access-list exclude'
    itd.destroy
  end

  def test_device_group
    itd = ItdService.new('new_group')
    config 'itd device-group myGroup'
    itd.device_group = 'myGroup'
    assert_equal('myGroup', itd.device_group)
    itd.device_group = itd.default_device_group
    assert_equal(itd.default_device_group,
                 itd.device_group)
    itd.destroy
  end

  def test_failaction
    itd = ItdService.new('new_group')
    itd.failaction = true
    assert_equal(true, itd.failaction)
    itd.failaction = itd.default_failaction
    assert_equal(itd.default_failaction,
                 itd.failaction)
    itd.destroy
  end

  def test_peer
    itd = ItdService.new('new_group')
    parray = %w(vdc1 ser1)
    itd.peer = parray
    assert_equal(parray, itd.peer)
    itd.peer = itd.default_peer
    assert_equal(itd.default_peer,
                 itd.peer)
    itd.destroy
  end

  def test_shutdown
    itd = ItdService.new('new_group')
    # need to configure a lot before doing this test
    # also there is a delay after shutdown, please take care
    itd.shutdown = false
    assert_equal(false, itd.shutdown)
    itd.shutdown = itd.default_shutdown
    assert_equal(itd.default_shutdown,
                 itd.shutdown)
    itd.destroy
  end

  # no vrf <vrf> does not work and so this test will fail
  def test_vrf
    itd = ItdService.new('new_group')
    itd.vrf = 'myVrf'
    assert_equal('myVrf', itd.vrf)
    itd.vrf = itd.default_vrf
    assert_equal(itd.default_vrf,
                 itd.vrf)
    itd.destroy
  end
end
