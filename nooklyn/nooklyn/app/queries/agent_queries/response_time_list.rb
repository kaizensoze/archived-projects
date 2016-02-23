module AgentQueries
  class ResponseTimeList

    def list
      result
    end

    private

    def result
      @_result ||= ActiveRecord::Base.connection.select_all(sql)
    end

    def sql
      <<-SQL
        WITH earliest_participant_response AS (
            SELECT
              conversation_participants.conversation_id,
              conversation_participants.agent_id,
              min(conversation_messages.created_at) AS earliest_response
            FROM conversation_participants
              INNER JOIN conversation_messages
                ON conversation_participants.conversation_id = conversation_messages.conversation_id
                   AND conversation_participants.agent_id = conversation_messages.agent_id
            GROUP BY 1, 2
        ), nooklyn_agents AS (
            SELECT id
            FROM agents
            WHERE agents.employee = TRUE OR agents.employer = TRUE OR agents.admin = TRUE OR agents.super_admin = TRUE
        ), conversations_with_agents AS (
            SELECT conversation_participants.conversation_id
            FROM conversation_participants
              INNER JOIN nooklyn_agents ON conversation_participants.agent_id = nooklyn_agents.id
            GROUP BY 1
        )
        SELECT
          agent_reply_stats.agent_id,
          agents.first_name,
          agents.last_name,
          round(agent_reply_stats.avg_response_secs :: NUMERIC, 2) AS avg_response_secs,
          agent_reply_stats.num_conversations
        FROM (
               SELECT
                 conversation_reply_stats.earliest_agent_id        AS agent_id,
                 avg(conversation_reply_stats.agent_response_secs) AS avg_response_secs,
                 count(*)                                          AS num_conversations
               FROM (
                      SELECT
                        conversations.id                                          AS conversation_id,
                        agent_responses.agent_id                                  AS earliest_agent_id,
                        EXTRACT(EPOCH FROM agent_responses.earliest_response -
                                           non_agent_responses.earliest_response) AS agent_response_secs,
                        agent_responses.earliest_response                         AS earliest_agent_reply,
                        non_agent_responses.earliest_response                     AS earliest_message,
                        non_agent_responses.agent_id                              AS earliest_user_id
                      FROM
                        conversations
                        INNER JOIN conversations_with_agents ON conversations.id = conversations_with_agents.conversation_id
                        INNER JOIN (
                                     SELECT
                                       earliest_participant_response.conversation_id,
                                       earliest_participant_response.agent_id,
                                       earliest_participant_response.earliest_response,
                                       row_number()
                                       OVER (PARTITION BY earliest_participant_response.conversation_id
                                         ORDER BY earliest_participant_response.earliest_response ASC) AS message_num
                                     FROM earliest_participant_response
                                       LEFT JOIN nooklyn_agents ON earliest_participant_response.agent_id = nooklyn_agents.id
                                     WHERE nooklyn_agents.id IS NULL
                                   ) non_agent_responses ON conversations.id = non_agent_responses.conversation_id
                        INNER JOIN (
                                     SELECT
                                       earliest_participant_response.conversation_id,
                                       earliest_participant_response.agent_id,
                                       earliest_participant_response.earliest_response,
                                       row_number()
                                       OVER (PARTITION BY earliest_participant_response.conversation_id
                                         ORDER BY earliest_participant_response.earliest_response ASC) AS message_num
                                     FROM earliest_participant_response
                                       INNER JOIN nooklyn_agents ON earliest_participant_response.agent_id = nooklyn_agents.id
                                   ) agent_responses ON conversations.id = agent_responses.conversation_id
                      WHERE
                        non_agent_responses.message_num = 1 AND agent_responses.message_num = 1
                    ) AS conversation_reply_stats
               WHERE conversation_reply_stats.earliest_user_id <> conversation_reply_stats.earliest_agent_id
               GROUP BY 1
               ORDER BY 2 ASC
             ) AS agent_reply_stats
          INNER JOIN agents ON agent_reply_stats.agent_id = agents.id
        WHERE agent_reply_stats.num_conversations >= 10
        ORDER BY agent_reply_stats.avg_response_secs;
      SQL
    end

  end
end
