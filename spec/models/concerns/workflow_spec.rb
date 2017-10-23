require 'spec_helper'

describe Workflow do
  before do
    lookup = Lookup.new(:id => "lookup-service-response-type",
                   :name => "Service Response Type",
                   :locked => true,
                   :lookup_values => [
                       {id: "care_plan", display_text: "Care plan"}.with_indifferent_access,
                       {id: "action_plan", display_text: "Action plan"}.with_indifferent_access,
                       {id: "service_provision", display_text: "Service provision"}.with_indifferent_access
                   ])
    @lookups = [lookup]

    @module_a = PrimeroModule.new(
        program_id: "module_a",
        associated_record_types: ['case'],
        name: "Test Module A",
        associated_form_ids: [],
        use_workflow_case_plan: true,
        use_workflow_assessment: true
    )

    @module_b = PrimeroModule.new(
        program_id: "module_b",
        associated_record_types: ['case'],
        name: "Test Module B",
        associated_form_ids: [],
        use_workflow_case_plan: true,
        use_workflow_assessment: true
    )
  end

  describe 'workflow_statuses' do
    context 'when there are multiple modules' do
      before do
        @modules = [@module_a, @module_b]
      end

      it 'returns a workflow status hash list' do
        status_list = Child.workflow_statuses(@modules, @lookups)
        expect(status_list).to include(include('id' => Workflow::WORKFLOW_NEW))
        expect(status_list).to include(include('id' => Workflow::WORKFLOW_REOPENED))
        expect(status_list).to include(include('id' => 'care_plan'))
        expect(status_list).to include(include('id' => 'action_plan'))
        expect(status_list).to include(include('id' => 'service_provision'))
        expect(status_list).to include(include('id' => Workflow::WORKFLOW_CLOSED))
      end

      context 'and no modules use workflow_assessment' do
        before do
          @module_a.use_workflow_assessment = false
          @module_b.use_workflow_assessment = false
        end

        it 'does not include Workflow Assessment in the status list' do
          expect(Child.workflow_statuses(@modules, @lookups)).not_to include(include('id' => Workflow::WORKFLOW_ASSESSMENT))
        end
      end

      context 'and one modules uses workflow_assessment' do
        before do
          @module_a.use_workflow_assessment = true
          @module_b.use_workflow_assessment = false
        end

        it 'does include Workflow Assessment in the status list' do
          expect(Child.workflow_statuses(@modules, @lookups)).to include(include('id' => Workflow::WORKFLOW_ASSESSMENT))
        end
      end

      context 'and both modules use workflow_assessment' do
        before do
          @module_a.use_workflow_assessment = true
          @module_b.use_workflow_assessment = true
        end

        it 'does include Workflow Assessment in the status list' do
          expect(Child.workflow_statuses(@modules, @lookups)).to include(include('id' => Workflow::WORKFLOW_ASSESSMENT))
        end
      end
    end
  end

  describe 'workflow_sequence_strings' do
    before do
      @test_obj = Child.new
      @test_obj.stub(:module).and_return(@module_a)
      @test_obj.stub(:case_status_reopened).and_return(false)
    end

    it 'returns a list of workflow strings' do
      workflow_strings = @test_obj.workflow_sequence_strings(@lookups)
      expect(workflow_strings).to include(["Care plan", "care_plan"])
      expect(workflow_strings).to include(["Action plan", "action_plan"])
      expect(workflow_strings).to include(["Service provision", "service_provision"])
      expect(workflow_strings).to include(["Closed", "closed"])
    end

    #TODO: WARNING - there is Case specific logic in this concern
    context 'when a case has been reopened' do
      before do
        @test_obj.stub(:case_status_reopened).and_return(true)
      end

      it 'returns a list of workflow strings having REOPENED' do
        expect(@test_obj.workflow_sequence_strings(@lookups)).to include(["Reopened", "reopened"])
      end

      it 'returns a list of workflow strings not having NEW' do
        expect(@test_obj.workflow_sequence_strings(@lookups)).not_to include(["New", "new"])
      end
    end

    context 'when a case has not been reopened' do
      before do
        @test_obj.stub(:case_status_reopened).and_return(false)
      end

      it 'returns a list of workflow strings not having REOPENED' do
        expect(@test_obj.workflow_sequence_strings(@lookups)).not_to include(["Reopened", "reopened"])
      end

      it 'returns a list of workflow strings having NEW' do
        expect(@test_obj.workflow_sequence_strings(@lookups)).to include(["New", "new"])
      end
    end
  end

  describe 'calculate_workflow' do
    before do
      FormSection.all.each &:destroy
      Lookup.all.each &:destroy
      PrimeroModule.all.each &:destroy

      Lookup.create(
          :id => "lookup-service-response-type",
          :name => "Service Response Type",
          :locked => true,
          :lookup_values => [
              {id: "care_plan", display_text: "Care plan"}.with_indifferent_access,
              {id: "action_plan", display_text: "Action plan"}.with_indifferent_access,
              {id: "service_provision", display_text: "Service provision"}.with_indifferent_access
          ]
      )

      services_subform = [
          Field.new({
                        "name" => "service_response_type",
                        "type" => "select_box",
                        "display_name_all" => "Type of Response",
                        "option_strings_source" => "lookup lookup-service-response-type"
                    }),
          Field.new({
                        "name" => "service_implemented",
                        "type" => "select_box",
                        "selected_value" => "not_implemented",
                        "display_name_all" => "Service Implemented",
                        "option_strings_text_all" => [
                            { id: 'not_implemented', display_text: "Not Implemented" }.with_indifferent_access,
                            { id: 'implemented', display_text: "Implemented" }.with_indifferent_access
                        ]
                    }),
      ]

      services_section = FormSection.create_or_update_form_section({
                                                                       "visible"=>false,
                                                                       "is_nested"=>true,
                                                                       :order_form_group => 110,
                                                                       :order => 30,
                                                                       :order_subform => 1,
                                                                       :unique_id=>"services_section",
                                                                       :parent_form=>"case",
                                                                       "editable"=>true,
                                                                       :fields => services_subform,
                                                                       :initial_subforms => 1,
                                                                       "name_all" => "Nested Services",
                                                                       "description_all" => "Services Subform",
                                                                       "collapsed_fields" => ["service_type", "service_appointment_date"]
                                                                   })

      services_fields = [
          Field.new({
                        "name" => "services_section",
                        "type" => "subform",
                        "editable" => true,
                        "subform_section_id" => services_section.unique_id,
                        "display_name_all" => "Services",
                        "subform_sort_by" => "service_appointment_date"
                    })
      ]

      case_plan_fields = [
          Field.new({"name" => "date_case_plan",
                     "type" => "date_field",
                     "display_name_all" => "Date Case Plan Initiated",
                     "editable" => true,
                     "disabled" => false
                    }),
          Field.new({"name" => "assessment_requested_on",
                     "type" => "date_field",
                     "display_name_all" => "Assesment Requested On",
                     "editable" => true,
                     "disabled" => false
                    }),
      ]

      form1 = FormSection.create_or_update_form_section({
                                                            :unique_id => "cp_case_plan",
                                                            :parent_form=>"case",
                                                            "visible" => true,
                                                            :order_form_group => 80,
                                                            :order => 10,
                                                            :order_subform => 0,
                                                            :form_group_name => "Case Plan",
                                                            "editable" => true,
                                                            :fields => case_plan_fields,
                                                            "name_all" => "Case Plan",
                                                            "description_all" => "Case Plan"
                                                        })

      form2 = FormSection.create_or_update_form_section({
                                                            :unique_id => "services",
                                                            :parent_form=>"case",
                                                            "visible" => true,
                                                            :order_form_group => 110,
                                                            :order => 30,
                                                            :order_subform => 0,
                                                            :form_group_name => "Services / Follow Up",
                                                            :fields => services_fields,
                                                            "editable" => false,
                                                            "name_all" => "Services",
                                                            "description_all" => "Services form",
                                                        })


      a_module = PrimeroModule.create!(
          program_id: "some_program",
          associated_record_types: ['case'],
          name: "Test Module",
          associated_form_ids: [form1.id, form2.id],
          use_workflow_case_plan: true,
          use_workflow_assessment: true
      )

      Child.refresh_form_properties

      # @case1 = create_child_with_created_by('bob123', name: 'Workflow Tester', module_id: a_module.id)
      user = User.new({:user_name => 'bob123', :organization=> "UNICEF"})
      @case1 = Child.new_with_user_name user, {name: 'Workflow Tester', module_id: a_module.id}
    end

    context 'when case is new' do
      it 'workflow status should be NEW' do
        expect(@case1.workflow).to eq(Workflow::WORKFLOW_NEW)
      end
    end

    context 'when case is open' do
      before :each do
        @case1.child_status = Record::STATUS_OPEN
      end

      context 'and date assesment initiated is set' do
        before do
          @case1.assessment_requested_on = Date.current
          @case1.save
        end

        it 'workflow status should be ASSESMENT' do
          expect(@case1.workflow).to eq(Workflow::WORKFLOW_ASSESSMENT)
        end
      end

      context 'and date case plan initiated is set' do
        before do
          @case1.date_case_plan = Date.current
          @case1.save
        end

        it 'workflow status should be CASE PLAN' do
          expect(@case1.workflow).to eq(Workflow::WORKFLOW_CASE_PLAN)
        end
      end

      context 'and service response type is set' do
        before do
          @case1.services_section << {service_response_type: 'action_plan', service_implemented: Serviceable::SERVICE_NOT_IMPLEMENTED}
          @case1.save!
        end
        it 'workflow status should be the response type of the service' do
          expect(@case1.workflow).to eq('action_plan')
        end
      end

      context 'and service response type is not set' do
        context 'and case has been reopened' do
          before do
            @case1.case_status_reopened = true
            @case1.save
          end
          it 'workflow status should be REOPENED' do
            expect(@case1.workflow).to eq(Workflow::WORKFLOW_REOPENED)
          end
        end
      end

    end

    context 'when case is closed' do
      before do
        @case1.child_status = Record::STATUS_CLOSED
        @case1.save!
      end

      it 'workflow status should be CLOSED' do
        expect(@case1.workflow).to eq(Workflow::WORKFLOW_CLOSED)
      end
    end

  end
end