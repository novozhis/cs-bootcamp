namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1283-capa1user"
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/Sergey
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: '${"sergey-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '13'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: on_failure
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      clone_vm:
        x: 553
        y: 44
      uuid:
        x: 100
        y: 150
      substring:
        x: 275
        y: 37
        navigate:
          f44d8ccc-a640-d184-58da-e785b5bfb9b2:
            vertices:
              - x: 535
                y: 80
            targetId: clone_vm
            port: SUCCESS
      power_on_vm:
        x: 763
        y: 119
      wait_for_vm_info:
        x: 548
        y: 289
        navigate:
          ab079339-ca44-724d-44d3-389f2ea0e2f2:
            targetId: c6c14748-8fb1-0f22-eebe-ff46bcc4c6e7
            port: SUCCESS
    results:
      SUCCESS:
        c6c14748-8fb1-0f22-eebe-ff46bcc4c6e7:
          x: 357
          y: 388
