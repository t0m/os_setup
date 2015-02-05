# os_setup-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['os_setup']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### os_setup::default

Include `os_setup` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[os_setup::default]"
  ]
}
```

## License and Authors

Author:: YOUR_NAME (<YOUR_EMAIL>)
